#!/usr/bin/env bash
# scripts/check-branch-protection.sh — verifies every non-archived
# Socx-Org repository's default branch satisfies ENG-010.5/.7/.8 and
# ADR-170's mandatory baseline (ENG-010.10's compliance-verification
# requirement).
#
# Deliberately checks every repository in the org (gh repo list), not a
# hardcoded list -- a repository someone forgot to add to a list is
# exactly the silent gap ENG-010.9 ("no repository is exempt pending
# future setup") exists to prevent. Archived repositories are skipped;
# nothing new is expected to land on them.
#
# What's checked (repo-agnostic, per ADR-170's 2026-08-08 amendment):
#   - branch protection exists at all on the default branch
#   - at least one required status check is configured (which check(s)
#     is repo-specific -- this script does not, and should not, assert
#     particular context names)
#   - at least one required approving review
#   - force-pushes disabled
#   - branch deletion disabled (on the protected branch itself)
#   - conversation resolution required
#   - delete-branch-on-merge enabled (ENG-010.8; a separate,
#     repository-level setting, not part of branch protection itself)
#
# What's deliberately NOT checked, and why:
#   - enforce_admins -- contributor-count-specific per ADR-170's
#     amendment (false is expected and correct for a genuine
#     single-contributor repository), not a uniform pass/fail signal
#   - required_status_checks.contexts' specific names -- repo-specific;
#     asserting particular job names here would make this script break
#     every time a repository renames a CI job, for no compliance value
#
# Usage:
#   ./scripts/check-branch-protection.sh
#
# Exit code: 0 if every checked repository is compliant, 1 otherwise.
# Requires: gh CLI, authenticated with read access to the Socx-Org
# organisation and admin read access to each repository's branch
# protection (the same access branch protection itself was applied
# with).

set -euo pipefail

ORG="Socx-Org"
FAILED=0

echo "== Discovering non-archived repositories in ${ORG} =="
REPOS="$(gh repo list "$ORG" --limit 200 --json name,isArchived,defaultBranchRef \
  --jq '.[] | select(.isArchived == false) | "\(.name) \(.defaultBranchRef.name // "main")"')"

if [ -z "$REPOS" ]; then
  echo "ERROR: no repositories found in ${ORG} (or gh is not authenticated)." >&2
  exit 1
fi

while IFS=' ' read -r repo branch; do
  echo
  echo "== ${ORG}/${repo} (${branch}) =="

  PROTECTION="$(gh api "repos/${ORG}/${repo}/branches/${branch}/protection" 2>/dev/null || echo "")"

  if [ -z "$PROTECTION" ]; then
    echo "FAIL: no branch protection configured (ENG-010.9 violation, or not yet applied)"
    FAILED=1
    continue
  fi

  CONTEXTS_COUNT="$(echo "$PROTECTION" | jq '.required_status_checks.contexts | length')"
  REVIEW_COUNT="$(echo "$PROTECTION" | jq '.required_pull_request_reviews.required_approving_review_count // 0')"
  FORCE_PUSH="$(echo "$PROTECTION" | jq -r '.allow_force_pushes.enabled')"
  ALLOW_DELETE="$(echo "$PROTECTION" | jq -r '.allow_deletions.enabled')"
  CONVO_RESOLUTION="$(echo "$PROTECTION" | jq -r '.required_conversation_resolution.enabled')"
  DELETE_ON_MERGE="$(gh api "repos/${ORG}/${repo}" --jq '.delete_branch_on_merge')"

  REPO_OK=1

  if [ "$CONTEXTS_COUNT" -lt 1 ]; then
    echo "FAIL: no required status checks configured (ENG-010.5)"
    REPO_OK=0
  fi
  if [ "$REVIEW_COUNT" -lt 1 ]; then
    echo "FAIL: required_approving_review_count is ${REVIEW_COUNT}, must be >= 1 (ENG-010.5)"
    REPO_OK=0
  fi
  if [ "$FORCE_PUSH" != "false" ]; then
    echo "FAIL: force-pushes are not disabled (ENG-010.7)"
    REPO_OK=0
  fi
  if [ "$ALLOW_DELETE" != "false" ]; then
    echo "FAIL: branch deletion is not disabled on the protected branch"
    REPO_OK=0
  fi
  if [ "$CONVO_RESOLUTION" != "true" ]; then
    echo "FAIL: conversation resolution is not required"
    REPO_OK=0
  fi
  if [ "$DELETE_ON_MERGE" != "true" ]; then
    echo "FAIL: delete_branch_on_merge is not enabled (ENG-010.8)"
    REPO_OK=0
  fi

  if [ "$REPO_OK" -eq 1 ]; then
    echo "OK: baseline satisfied (${CONTEXTS_COUNT} required check(s), enforce_admins=$(echo "$PROTECTION" | jq -r '.enforce_admins.enabled') -- contributor-count-specific, not checked above)"
  else
    FAILED=1
  fi
done <<< "$REPOS"

echo
if [ "$FAILED" -eq 0 ]; then
  echo "All repositories satisfy the ENG-010/ADR-170 branch-protection baseline."
else
  echo "One or more repositories do not satisfy the baseline. See FAIL lines above." >&2
fi

exit "$FAILED"
