# GitHub Development Workflow

## Purpose

All work must be tracked in GitHub before implementation begins.

This workflow is mandatory for all code, documentation and infrastructure changes.

---

# Repository

GitHub Organisation

Socx-Org

GitHub Project: Project #1

#1

Project #1's Status field has exactly three values: **Todo**, **In Progress**, **Done**. There is no separate "Backlog" status — Todo serves that purpose. Every reference to "Backlog" below means Status = Todo.

---

# Workflow

Every task follows this lifecycle. Only three stages (Todo, In Progress, Done) are actual Project Status values; the rest (Planning, Approved, Implementation, Review, Commit) are process checkpoints that happen while an Issue sits at one of those three statuses.

Idea
↓
Issue Created
↓
Todo (Backlog)
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
- set Status = Todo
- present the implementation plan
- wait for approval

No implementation should begin before approval.

---

# Phase 2 – Implementation

When implementation begins:

Move the Project Status to:

In Progress

`scripts/gh-issue-status.sh <issue-number> "In Progress"` does this without hand-crafting the GraphQL mutation and Project #1's field/option IDs each time — same script, same three states, for every Status transition in this document.

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

* first detailed commit message
* second detailed commit message

 Deliverable: 6 - Title

Status: <Draft | Approved | In Progress | Done>

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

---

# Recorded Exceptions

Exceptions to Engineering Standards, per `GEN-010.9`–`GEN-010.10`. An exception here is a deliberate, documented deviation with a stated reason and review trigger — never a silent gap.

## `ENG-010.2`, `ENG-010.5` — direct commits to `main`

**Requirement:** `ENG-010.2` requires all changes via a short-lived branch and pull request, with direct pushes to `main` disabled. `ENG-010.5` requires `main` to be a protected branch, requiring an independent approving review and a passing CI status check before merge.

**Actual practice:** this repository is authored via direct commits to `main` by a single contributor (the platform owner, working conversationally with an AI assistant) — every change is reviewed in that conversation before commit, but not via a GitHub pull request, and `main` currently has no branch protection or required CI status check.

**Reason:** this is exactly the scenario `ENG-010.6` itself anticipates — a single-contributor repository — and the standards' own exception mechanism (`GEN-010.9`) is the correct route, not a policy debate. `reference/github` (Deliverable 6.4, `#70`) defines the canonical branch-protection configuration this repository would adopt; applying it now, mid-engagement, would block the active, ongoing authoring work with a PR+review+CI-status-check gate this repository doesn't yet have CI wired up to satisfy.

**Review trigger:** revisit when `reference/github`'s branch protection is applied for real (a deliberate decision tracked in `#70`, not a mechanical step), or at the next annual standards review, **2027-08-06**, whichever comes first.

**Recorded:** 2026-08-06.

**Closed: 2026-08-07.** Branch protection is applied to `main` for real (`#70`). One real, structural blocker surfaced before this could happen: `main`/`ENG-010.5`-style protection on a **private** repository requires GitHub Pro on this account's plan — confirmed via a real, rejected API call, not assumed. The platform owner made the repository **public** to unblock this, a deliberate decision made explicitly for this purpose (previously-committed non-secret-but-real infrastructure detail — Cloudflare zone ID, SSH key fingerprint, real domain — is now publicly readable as a result; nothing secret per `SEC-010.1` was ever committed).

The applied configuration is a deliberate, documented adaptation of `reference/github/branch-protection.json`'s canonical template, not a verbatim copy — two changes, both load-bearing:

- `required_status_checks.contexts` is `["Repository Checks"]`, not `["Install, Lint, Test, Build"]`. The canonical template's context is `reference/github/workflows/ci.yml`'s job name, built for a Node/TS/Express application — this repository has no such application. `.github/workflows/ci.yml` was authored fresh for what this repository actually is (Markdown, shell scripts, Terraform reference config): `scripts/check-reference-compliance.sh`, `shellcheck` on every shell script, `terraform fmt`/`validate` on `reference/terraform`. Verified for real on the actual GitHub Actions runner before protection was ever applied — including one genuine failure (`terraform` isn't preinstalled on `ubuntu-latest`, unlike `shellcheck`) found and fixed by actually running it, not assumed working.
- `enforce_admins: false`, not `true`. `ENG-010.6` anticipates exactly this repository's shape — single-contributor — and `reference/github`'s own compliance notes already flagged that an author's own review never counts toward `required_approving_review_count`. Applied verbatim (`enforce_admins: true`), this repository would have become permanently unable to merge its own work, having no second reviewer. `enforce_admins: false` preserves the protection for anyone else (no direct push, no force-push, no unreviewed merge) while giving the actual repository admin a working bypass — confirmed for real: a direct push to `main` was attempted immediately after applying protection and succeeded with an explicit "Bypassed rule violations" warning, exactly as intended, then reverted.

Direct-to-`main` commits are no longer the working pattern for this repository going forward — real PRs, real CI, real review where a second reviewer exists.
