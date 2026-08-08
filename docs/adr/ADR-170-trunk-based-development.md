---
id: ADR-170
title: Trunk-based development & commit conventions
status: Approved
category: Engineering Process
version: "1.1"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture: []
  standards:
    - ENG-010
  current_state:
    - REP-010
  reference:
    - reference/github
  runbooks: []
  adrs:
    - ADR-150
supersedes: []
superseded_by: null
---

# ADR-170 — Trunk-based development & commit conventions

## Context

A consistent branching and commit model lets branch protection, release tooling, and changelog generation be configured the same way across every repository, and keeps history legible for onboarding and auditing. `ENG-010` already specifies the mechanics; `REP-010` confirms every repository already defaults to `main`. This ADR records the decision *behind* that standard — why trunk-based development over the alternatives.

## Decision

Every repository uses **trunk-based development** on a single long-lived default branch (`main`). All changes are made on short-lived branches and merged via pull request; direct pushes and force-pushes to `main` are disabled. `main` requires an independent approving review and a passing CI status check before merge, and branches are deleted after merge. Commits follow **Conventional Commits** (`type(scope): summary`), and branches are type-prefixed (`feature/`, `fix/`, `chore/`, `docs/`). The single-contributor exception to independent review is handled by `GEN-010`'s exception process, not here.

**Amendment (2026-08-08):** branch protection under this decision is a **standing, repeatable pattern every SOCX repository goes through** — `socx-platform`, `rms`, `ghs`, `ams`, and every repository created after them — not a configuration `socx-platform` happened to choose for itself. `ENG-010.9`–`.10` (added this round) make the timing and continued-compliance obligations explicit; this amendment records the *decision* behind them, matching this ADR's role (`ENG-010` is the baseline, `reference/github` is the implementation, `scripts/check-branch-protection.sh` is the verification — this ADR is the why).

Applying this for real to `socx-platform` (`2026-08-07`) surfaced two facts now elevated from that one repository's own exception record to a standing part of this decision, since they will recur for every early-stage SOCX repository, not just this one:

- **Branch protection of any kind requires the repository to be public, or the account to have GitHub Pro.** Confirmed via a real, rejected API call against both the classic branch-protection endpoint and the newer rulesets endpoint — not documentation, not assumption. A repository intending to stay private needs a paid plan before this decision can be enforced on it at all.
- **`enforce_admins: false` is the expected configuration for a genuinely single-contributor repository**, not a `socx-platform`-specific deviation from a `true` default. `ENG-010.6` already anticipated this scenario; `enforce_admins: true` combined with `required_approving_review_count >= 1` and no second reviewer makes a repository permanently unable to merge its own work. The review trigger is the same for every repository this applies to: revisit when a genuine second reviewer joins that specific repository, not on a fixed schedule.

Neither of these changes what `ENG-010.5`–`.7` require — they record what satisfying those requirements actually looks like, in practice, for the shape every SOCX repository starts in.

## Alternatives Considered

- **Git Flow (long-lived `develop` plus `release/*` branches)** — Rejected: heavier than needed; long-lived parallel branches complicate branch protection and CI and let history diverge.
- **Indefinitely retained release branches** — Rejected for the same reason; trunk-based keeps a single integration point.
- **No enforced model** — Rejected: bespoke per-repository history defeats shared tooling and auditability.

## Consequences

- Branch-protection, release, and changelog tooling are configured once and reused (`reference/github`, `templates/github`).
- Conventional Commits enables automated changelog and version generation later.
- Small teams feel the independent-review requirement most; `GEN-010`'s exception covers genuine single-contributor repositories.
- This ADR documents an already-standardised practice (`ENG-010`); its value is the recorded rationale, not a new rule — and it defines the CI status check that `ADR-150`'s pipelines must satisfy.
- Every future SOCX repository inherits this decision from the moment its CI first passes (`ENG-010.9`) — there is no grace period, and `scripts/check-branch-protection.sh` (`ENG-010.10`) exists specifically so a repository that skipped this step is a detectable drift, not a silent gap discovered later. `required_status_checks.contexts` is necessarily repo-specific (whichever jobs actually run on that repository's pull requests — never a push-only job, which would make every PR permanently unmergeable); `enforce_admins` is contributor-count-specific, not repository-type-specific. Neither variation weakens `ENG-010.5`–`.8`'s baseline.

## Related Documents

- Architecture: none
- Standards: `ENG-010`
- Current-State documentation: `REP-010`
- Reference Implementations: `reference/github`
- Runbooks: none
- ADRs: `ADR-150` (CI/CD, which provides the required status check)
- Automation: `scripts/check-branch-protection.sh` (compliance verification, `ENG-010.10`)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
| 1.1     | 2026-08-08 | Amendment: elevated the public-repo/GitHub-Pro constraint and the single-contributor `enforce_admins: false` pattern from `socx-platform`'s own exception record to a standing part of this decision, applying to every SOCX repository; recorded the relationship to `ENG-010.9`–`.10` and `scripts/check-branch-protection.sh` | Socx |
