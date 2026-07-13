---
id: ADR-170
title: Trunk-based development & commit conventions
status: Approved
category: Engineering Process
version: "1.0"
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

## Alternatives Considered

- **Git Flow (long-lived `develop` plus `release/*` branches)** — Rejected: heavier than needed; long-lived parallel branches complicate branch protection and CI and let history diverge.
- **Indefinitely retained release branches** — Rejected for the same reason; trunk-based keeps a single integration point.
- **No enforced model** — Rejected: bespoke per-repository history defeats shared tooling and auditability.

## Consequences

- Branch-protection, release, and changelog tooling are configured once and reused (`reference/github`, `templates/github`).
- Conventional Commits enables automated changelog and version generation later.
- Small teams feel the independent-review requirement most; `GEN-010`'s exception covers genuine single-contributor repositories.
- This ADR documents an already-standardised practice (`ENG-010`); its value is the recorded rationale, not a new rule — and it defines the CI status check that `ADR-150`'s pipelines must satisfy.

## Related Documents

- Architecture: none
- Standards: `ENG-010`
- Current-State documentation: `REP-010`
- Reference Implementations: `reference/github`
- Runbooks: none
- ADRs: `ADR-150` (CI/CD, which provides the required status check)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
