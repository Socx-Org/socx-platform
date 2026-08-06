
# GitHub Development Workflow

## Purpose

All work must be tracked in GitHub before implementation begins.

This workflow is mandatory for all code, documentation and infrastructure changes.

---

# Repository

GitHub Organisation: Socx-Org

GitHub Project: Project #1

#1

---

# Workflow

Every task follows this lifecycle.

Idea
↓
Issue Created
↓
Backlog
↓
Planning
↓
Approved
↓
In Progress
↓
Implementation
↓
Review
↓
Approved
↓
Commit
↓
Done
↓
Issue Closed

---

# Phase 1 – Planning

Before implementation Claude must:

- search for an existing Issue
- create one if none exists
- write a clear Issue description
- add acceptance criteria
- add the Issue to Project #1
- set Status = Backlog
- present the implementation plan
- wait for approval

No implementation should begin before approval.

---

# Phase 2 – Implementation

When implementation begins:

Move the Project Status to:

In Progress

Implementation should:

- keep documentation updated
- update ADRs where necessary
- update reference implementations
- avoid unrelated changes

---

# Phase 3 – Review

When implementation is complete:

Do NOT commit.

Instead:

- summarise completed work
- identify changed files
- identify documentation updates
- ask for review

Wait for approval.

---

# Phase 4 – Commit

Only after approval:

Create a commit using:

#<issue-number></issue> <type></type>(<scope></scope>): 


























Example

#68 docs(reference): refine reference/systemd manifest

---

Commit Types

feat
fix
docs
refactor
test
build
ci
perf
style
chore

---

# Phase 5 – Completion

After committing:

Move Project Status to:

Done

Close the GitHub Issue.

Add a closing comment containing:

- summary of work
- commit hash
- documentation updated
- follow-up work (if any)

Example

Completed.

Summary

- Updated reference manifest.
- Added prerequisite section.
- Added design decisions.

Commit

abc1234

Documentation

Updated.

Follow-up

None.

---

# General Rules

Never implement work that is not associated with a GitHub Issue.

Never commit before review.

Never close an Issue before the commit succeeds.

Never skip Project updates.

Keep Issue descriptions and documentation synchronised with implementation.
