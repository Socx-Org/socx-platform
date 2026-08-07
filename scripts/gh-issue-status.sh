#!/usr/bin/env bash
# scripts/gh-issue-status.sh — moves a GitHub issue's Project #1 Status
# field (Todo / In Progress / Done) without hand-crafting the GraphQL
# mutation and its field/option IDs each time.
#
# This automates a mutation typed out by hand well over a dozen times
# during this repository's own history -- get the issue's project item
# ID, then a mutation naming Project #1's Status field ID and the target
# option's ID, both of which are constant for this project but not
# something worth re-deriving from memory every time.
#
# Usage:
#   ./scripts/gh-issue-status.sh <issue-number> <Todo|"In Progress"|Done>
#
# Requires: gh CLI, authenticated with access to Socx-Org/socx-platform
# and Project #1.

set -euo pipefail

REPO_OWNER="Socx-Org"
REPO_NAME="socx-platform"

# Project #1 constants -- confirmed via a real GraphQL query against this
# project (see docs/development/github-workflow.md for the project's own
# description). These do not change unless the project itself is rebuilt.
PROJECT_ID="PVT_kwDOEX2dOc4BdIFL"
STATUS_FIELD_ID="PVTSSF_lADOEX2dOc4BdIFLzhXr3l4"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <issue-number> <Todo|\"In Progress\"|Done>" >&2
  exit 1
fi

ISSUE_NUMBER="$1"
STATUS_NAME="$2"

case "$STATUS_NAME" in
  Todo) OPTION_ID="f75ad846" ;;
  "In Progress") OPTION_ID="47fc9ee4" ;;
  Done) OPTION_ID="98236657" ;;
  *)
    echo "ERROR: unknown status '${STATUS_NAME}' -- must be exactly Todo, \"In Progress\", or Done." >&2
    exit 1
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not found." >&2
  exit 1
fi

echo "Looking up issue #${ISSUE_NUMBER}'s Project #1 item..."
# shellcheck disable=SC2016 # single-quoted deliberately: $owner/$name/$number
# are GraphQL variables passed via -f/-F below, not shell variables.
ITEM_ID="$(gh api graphql -f query='
  query($owner: String!, $name: String!, $number: Int!) {
    repository(owner: $owner, name: $name) {
      issue(number: $number) {
        projectItems(first: 5) {
          nodes { id project { number } }
        }
      }
    }
  }' -f owner="$REPO_OWNER" -f name="$REPO_NAME" -F number="$ISSUE_NUMBER" \
  --jq '.data.repository.issue.projectItems.nodes[] | select(.project.number == 1) | .id')"

if [ -z "$ITEM_ID" ]; then
  echo "ERROR: issue #${ISSUE_NUMBER} has no Project #1 item -- add it first (gh project item-add)." >&2
  exit 1
fi

echo "Setting Status = ${STATUS_NAME}..."
# shellcheck disable=SC2016 # same as above -- GraphQL variables, not shell ones.
gh api graphql -f query='
  mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $project
      itemId: $item
      fieldId: $field
      value: { singleSelectOptionId: $option }
    }) { projectV2Item { id } }
  }' -f project="$PROJECT_ID" -f item="$ITEM_ID" -f field="$STATUS_FIELD_ID" -f option="$OPTION_ID" \
  >/dev/null

echo "Done: issue #${ISSUE_NUMBER} -> ${STATUS_NAME}"
