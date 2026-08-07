# GitHub Development Workflow

## Purpose

All work must be tracked in GitHub before implementation begins.

This workflow is mandatory for all code, documentation and infrastructure changes.

## Applicability

This document is the shared operational workflow governed by `ENG-070`. It lives in `socx-platform` and is followed **by reference**, not by copy, by every SOCX repository — `socx-platform` itself, `RMS`, and future application repositories (`GHS`, `AMS`). A repository's own `CLAUDE.md` should point here rather than restate this document.

The process (Phases 1–5 below) is the same everywhere. What differs between repositories is which GitHub Project and Status model applies:

| Repository work                                                        | GitHub Project                          | Status model |
| ------------------------------------------------------------------------ | ---------------------------------------- | ------------- |
| `socx-platform`'s own governance and deliverable tracking                | Project #1 (`socx-platform`)             | `Todo` → `In Progress` → `Done` |
| Application-development work (any `Product: RMS`/`GHS`/`AMS` item, and Platform Evolution items) | Project #2 (`SOCX Application Modernisation`, org-level) | `Backlog` → `Ready` → `In Progress` → `In Review` → `Done` |

This split is a deliberate design decision (`ENG-070.3`, `ADR-190`), not an inconsistency: platform-governance work and application delivery are different in shape, and each Project's Status model reflects that.

Everywhere below, "Backlog" means whichever of the two leftmost Status values applies to the repository doing the work (`Todo` for Project #1, `Backlog` for Project #2).

---

# Workflow

Every task follows this lifecycle. The Status values in the table above are the only real Project Status values; the rest (Planning, Approved, Implementation, Review, Commit) are process checkpoints that happen while an Issue sits at one of those Status values.

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
Ready *(Project #2 work only — see Definition of Ready)*
↓
In Progress
↓
Implementation
↓
Review
↓
Approved
↓
In Review *(Project #2 work only)*
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
- create one if none exists, using the appropriate template from `templates/github/ISSUE_TEMPLATE/`
- write a clear Issue description
- add acceptance criteria
- set the Issue Type (`Epic`/`Feature`/`Task`/`Bug`/`Spike`) — not a label
- for an Epic: state its ADR dependencies and ADR Status per `ENG-070.6`
- add the Issue to the repository's GitHub Project
- set Status = Backlog
- present the implementation plan
- wait for approval

No implementation should begin before approval.

---

# Definition of Ready

Before an Issue moves to `Ready` (Project #2) or is picked up for implementation (Project #1), per `ENG-070.4`:

- written acceptance criteria exist
- ADR Status is not `New ADR Required` — any architectural dependency is resolved or explicitly accepted as non-blocking
- identified blocking dependencies are resolved or explicitly accepted by the accountable lead
- there is no open question requiring a decision from the accountable architect or lead

If any of these fail, the Issue stays at Backlog until they are resolved — do not move it forward and note the gap instead.

---

# Phase 2 – Implementation

When implementation begins:

Move the Project Status to:

In Progress

`scripts/gh-issue-status.sh <issue-number> "In Progress"` does this for Project #1 without hand-crafting the GraphQL mutation and field/option IDs each time. Project #2's Status transitions currently use direct GraphQL (its field/option IDs differ from Project #1's, and the richer five-state set is out of this script's scope).

Implementation should:

- keep documentation updated
- update ADRs where necessary
- update reference implementations
- avoid unrelated changes
- where a change belongs to the platform itself rather than the application being worked on, route it through Platform Evolution instead of folding it into the current Issue (see below)

---

# Platform Evolution boundary

Per `ENG-070.7`: if application-specific work surfaces a genuine improvement to the SOCX Engineering Platform itself — a new or amended ADR, a Standards change, a reference-implementation update, a runbook, or platform tooling — that improvement is tracked as its own Issue under the Platform Evolution epic (`Product: Platform-Wide`, Project #2) and implemented in `socx-platform`'s own repository under `socx-platform`'s own workflow (Project #1 if it's platform-governance work, or straight through this same process if it's a real code/tooling change to the platform). It is never implemented inside the application repository's Epic. Identify the dependency relationship between the application Issue and the Platform Evolution Issue rather than duplicating the work.

---

# Phase 3 – Review

When implementation is complete:

Do NOT commit.

Instead:

- summarise completed work
- identify changed files
- identify documentation updates
- confirm the Definition of Done checklist (below) is satisfied
- ask for review

Wait for approval.

---

# Definition of Done

Before an Issue moves to `Done`, per `ENG-070.5`:

- tests pass for real (executed, not merely written)
- documentation is updated in the same change, not deferred
- no new `SEC-010` violation is introduced
- compliance with the ADRs and Standards the Issue depends on is confirmed
- the relevant runbook is updated where the change is operationally significant

---

# Phase 4 – Commit

Only after approval:

Create a commit using the format defined in `ENG-010.4`:

```
#<issue-number> <type>(<scope>): <summary>

* first detailed commit message
* second detailed commit message
```

Example

```
#68 docs(reference): refine reference/systemd manifest

* first detailed commit message
* second detailed commit message
```

Commit Types (per `ENG-010.4`): `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `build`, `ci`, `perf`, `style`.

For repositories with real branch protection (a required status check and, where a second reviewer exists, an independent approving review — see `ENG-010.5`), the commit lands via pull request, not a direct push to `main`. See `templates/github/PULL_REQUEST_TEMPLATE.md` for the required PR body.

---

# Phase 5 – Completion

After committing:

Move Project Status to:

Done

Close the GitHub Issue.

Add a closing comment containing:

- summary of work
- commit hash (or PR number)
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

Never restate this document or `ENG-070` inside a repository-specific `CLAUDE.md` — point at them instead (`ENG-070.9`).

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

## `ENG-070.9` — commit-format and Status-model drift preceding this document's generalisation

**Requirement:** `ENG-070.9` requires this document and `ENG-070` to be the single referenced source every SOCX repository follows.

**Actual practice:** before this document was generalised (`ADR-190`, 2026-08-08), RMS's first commits used a plain Conventional Commits header with a trailing issue reference rather than `ENG-010.4`'s issue-number prefix, and a four-state Status model was briefly drafted before being rejected in favour of the five-state model already in use on Project #2.

**Reason:** this document, and the standard now governing it (`ENG-070`), did not exist yet — RMS's early work had nothing authoritative to reference beyond `socx-platform`'s own informal practice, imitated rather than pointed to.

**Review trigger:** none — closed by this document's generalisation and `ENG-070`'s adoption. RMS's existing commit history is not rewritten; the format applies going forward.

**Recorded and closed: 2026-08-08.**
