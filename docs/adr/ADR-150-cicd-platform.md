---
id: ADR-150
title: CI/CD platform
status: Approved
category: Operations
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - TEC-010
  standards:
    - ENG-040
    - OPS-020
    - OPS-030
  current_state:
    - CS-TEC-010
    - REP-010
  reference:
    - reference/github
  runbooks: []
  adrs:
    - ADR-170
    - ADR-040
    - ADR-160
supersedes: []
superseded_by: null
---

# ADR-150 — CI/CD platform

## Context

CI/CD needs one platform-wide provider so that `ENG-040` pipelines, the branch-protection status check required by `ADR-170`, and deploy automation are configured consistently rather than per repository. `CS-TEC-010` confirms **GitHub Actions is already in use** — `ghs` and `rms` both have committed `.github/workflows/ci.yml`. `REP-010` notes the repositories are mid-migration between the `github.com/socx/*` and `Socx-Org/*` organisations.

## Decision

**GitHub Actions** is confirmed as the platform's CI/CD provider, standardised through reusable workflow templates (`reference/github`, `templates/github`), targeting the `Socx-Org` organisation as the migration lands. The choice between GitHub-hosted and self-hosted runners is left to the workflow templates, not fixed here.

## Alternatives Considered

- **GitHub Actions — selected.** Already in use; native to where the code, issues, and project board live; no additional vendor or credential surface.
- **A standalone CI (CircleCI / GitLab CI / Jenkins)** — Rejected: introduces a second platform and credential set for no evidenced benefit, when the code and project already live on GitHub.
- **GitHub-hosted vs self-hosted runners** — an implementation sub-choice deferred to the workflow templates, not settled in this ADR.

## Consequences

- `ENG-040` and `ADR-170`'s required status check target a single provider.
- The organisation migration (`socx` → `Socx-Org`) means workflow and secret configuration must be re-established in the target org; a migration checklist is follow-up work.
- Deploy automation for the hosting model (`ADR-040` / `OPS-030`) plugs into Actions, and secrets it needs are delivered per `ADR-130`.

## Related Documents

- Architecture: `TEC-010`
- Standards: `ENG-040`, `OPS-020`, `OPS-030`
- Current-State documentation: `CS-TEC-010`, `REP-010`
- Reference Implementations: `reference/github`, `reference/deployment` (the deploy job's real steps — Approved, verified on-host 2026-08-07)
- Runbooks: none yet
- ADRs: `ADR-170` (the status check CI provides), `ADR-040` (what pipelines deploy to), `ADR-160` (IaC the pipeline may apply)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
