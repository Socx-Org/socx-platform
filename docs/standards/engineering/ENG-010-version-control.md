---
id: ENG-010
title: Version Control & Branching
category: Engineering
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs:
    - ADR-170
  reference:
    - reference/github
  templates:
    - templates/github
supersedes: []
superseded_by: null
---
# ENG-010 — Version Control & Branching

## Scope

Applies to source control practice for every SOCX project repository: branching model, commit message format, pull request and branch-protection requirements.

Does not cover CI/CD pipeline stages (see `ENG-040`) or the substance of what a reviewer checks for (see `ENG-020`) — this standard governs the mechanics of using git, not what a good review looks for.

## Rationale

A consistent branching and commit model lets branch-protection rules, release tooling, and changelog generation be configured the same way across every SOCX project instead of bespoke per repository. It also keeps history legible for onboarding and auditing.

## Requirements

1. `ENG-010.1` — Every project MUST use trunk-based development with a single long-lived default branch (`main`). Long-lived parallel branches (e.g. a permanent `develop`, or `release/*` branches kept indefinitely) MUST NOT be used.
2. `ENG-010.2` — All changes MUST be made on a short-lived branch and merged via pull request. Direct pushes to `main` MUST be disabled.
3. `ENG-010.3` — Branch names MUST be prefixed by type — `feature/`, `fix/`, `chore/`, or `docs/` — followed by a short kebab-case description, e.g. `fix/login-timeout`.
4. `ENG-010.4` — Commit messages MUST follow Conventional Commits (`type(scope): summary`), where `type` is one of `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`.
5. `ENG-010.5` — `main` MUST be a protected branch requiring at least one independent approving review and a passing CI status check before merge.
6. `ENG-010.6` — A pull request MUST NOT be merged by its own author, unless the repository has only one contributor — in which case this requirement MAY be excepted per `GEN-010.9`.
7. `ENG-010.7` — Force-pushes to `main` MUST be disabled at the branch-protection level.
8. `ENG-010.8` — Branches MUST be deleted after merge, and MUST NOT be left idle for more than 30 days without either activity or deletion.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github` (branch-protection configuration, once populated)
- ADR(s): `ADR-170`
- Template(s): `templates/github` (once populated)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-12 | `ENG-010.5` now explicitly requires the approving review to be independent (non-author) | Socx |
| 1.2     | 2026-07-14 | Added ADR cross-references | Socx   |
