#!/usr/bin/env bash
# scripts/check-reference-compliance.sh — validates reference/'s own
# "no empty scaffolds" rule (reference/README.md's Lifecycle & Status):
# an Approved manifest must carry a non-null, real verified field. Also
# cross-checks reference/README.md's ToC against each manifest's own
# frontmatter status, and flags stale "(currently empty)"/"none yet"
# annotations elsewhere in docs/ for a category that is now Approved.
#
# This automates exactly the manual grep-and-review pass repeated by hand
# at the end of every Deliverable 6/7 round in this repository's history —
# cheap to skip by accident once, easy to keep doing forever once scripted.
#
# Usage: ./scripts/check-reference-compliance.sh [repo-root]
# Exit code: 0 if clean, 1 if any violation found.

set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
REFERENCE_DIR="${REPO_ROOT}/reference"
TOC="${REFERENCE_DIR}/README.md"
FAILED=0

if [ ! -d "$REFERENCE_DIR" ]; then
  echo "ERROR: ${REFERENCE_DIR} not found." >&2
  exit 1
fi

echo "== Checking: status: Approved requires a non-null verified =="
while IFS= read -r manifest; do
  category="$(basename "$(dirname "$manifest")")"
  status="$(grep -m1 '^status:' "$manifest" | sed 's/^status:[[:space:]]*//')"

  if [ "$status" = "Approved" ]; then
    verified_line="$(grep -m1 '^verified:' "$manifest" || true)"
    if [ -z "$verified_line" ] || echo "$verified_line" | grep -qE '^verified:[[:space:]]*null([[:space:]]|$)'; then
      echo "FAIL: reference/${category}/README.md — status: Approved but verified is null/missing" >&2
      FAILED=1
    fi
  fi
done < <(find "$REFERENCE_DIR" -mindepth 2 -maxdepth 2 -name "README.md" | sort)

echo "== Checking: reference/README.md's ToC matches each manifest's real status =="
while IFS= read -r manifest; do
  category="$(basename "$(dirname "$manifest")")"
  real_status="$(grep -m1 '^status:' "$manifest" | sed 's/^status:[[:space:]]*//')"
  toc_row="$(grep -E "^\| [0-9]+ \| \`reference/${category}\`" "$TOC" || true)"

  if [ -z "$toc_row" ]; then
    echo "FAIL: reference/${category} has a manifest but no row in reference/README.md's ToC" >&2
    FAILED=1
    continue
  fi

  toc_status="$(echo "$toc_row" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $5); print $5}')"
  if [ "$toc_status" != "$real_status" ]; then
    echo "FAIL: reference/README.md ToC says '${toc_status}' for reference/${category}, but its manifest says '${real_status}'" >&2
    FAILED=1
  fi
done < <(find "$REFERENCE_DIR" -mindepth 2 -maxdepth 2 -name "README.md" | sort)

echo "== Checking: no stale 'currently empty'/'none yet' annotation for an Approved category =="
while IFS= read -r manifest; do
  category="$(basename "$(dirname "$manifest")")"
  real_status="$(grep -m1 '^status:' "$manifest" | sed 's/^status:[[:space:]]*//')"

  if [ "$real_status" = "Approved" ]; then
    # Requires the annotation immediately after the path (optionally
    # backtick-quoted) -- not just proximity within the same line, which
    # false-positives on prose like `removed ... from the "currently
    # empty" list` (a real hit found and fixed during this script's own
    # on-repo verification: platform-bootstrap-log.md's line 433).
    hits="$(grep -rlE "reference/${category}\`? \((currently empty|none yet)" "${REPO_ROOT}/docs" 2>/dev/null || true)"
    if [ -n "$hits" ]; then
      echo "FAIL: stale 'currently empty'/'none yet' annotation for Approved reference/${category} in:" >&2
      echo "$hits" | sed 's/^/  /' >&2
      FAILED=1
    fi
  fi
done < <(find "$REFERENCE_DIR" -mindepth 2 -maxdepth 2 -name "README.md" | sort)

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "OK: no violations found."
else
  echo "FAILED: violations found above." >&2
fi
exit "$FAILED"
