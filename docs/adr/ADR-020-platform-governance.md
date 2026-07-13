---
id: ADR-020
title: "Platform governance: multi-repo topology & documentation model"
status: Draft
category: Platform & Governance
version: "0.1"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - CTX-010
    - DOM-010
  standards:
    - GEN-010
    - DOC-010
    - DOC-020
    - ENG-050
  current_state:
    - REP-010
  reference: []
  runbooks: []
  adrs:
    - ADR-010
    - ADR-030
supersedes: []
superseded_by: null
---

# ADR-020 — Platform governance: multi-repo topology & documentation model

## Context

The SOCX platform spans several applications plus shared infrastructure. Two structural questions had to be answered before any engineering content could accumulate coherently: how the code is split across repositories, and how the engineering knowledge itself is organised. `REP-010` confirms the real footprint — a governance repository (`socx-platform`), a shared-infrastructure repository (`platform-infra`), and four application repositories (`socx-org-uk`, `ghs`, `rms`, `ams`) — currently mid-migration between the `github.com/socx/*` and `Socx-Org/*` organisations. The project charter records the docs-only intent; this ADR records *why* this shape was chosen over the alternatives.

## Decision

The platform is governed through two linked structural decisions:

1. **Multi-repository topology.** `socx-platform` is the engineering source of truth and holds no application code. Each system lives in its own repository. `platform-infra` is the single shared runtime/edge repository. Application code never enters `socx-platform`.
2. **Separated documentation model.** Engineering knowledge is split into six document types — Architecture, Current-State, Standards, ADRs, Reference Implementations, and Runbooks — each following "one concept per document," carrying a permanent ID, and governed by its own lifecycle.

## Alternatives Considered

- **Monorepo (all applications and governance in one repository)** — Rejected: couples otherwise-independent release cycles and blurs per-system ownership.
- **Governance embedded in each application repository** — Rejected: yields no single source of truth; standards and architecture drift copy-by-copy across repositories.
- **A single wiki or one large document** — Rejected: no separable lifecycle, stable IDs, or reviewable unit, so a specific decision or standard cannot be cited precisely from elsewhere.

## Consequences

- `socx-platform` can be reviewed, versioned, and governed independently of any application.
- The cross-document reference system (every other ADR, standard, and architecture doc citing IDs) depends on the stable-ID model this decision establishes.
- The charter currently lists only three applications; `REP-010` found a fourth (`ams`) plus `platform-infra`. The topology decision holds, but the charter's repository list needs reconciling — a follow-up.
- The mid-migration between GitHub organisations is the operational reality this topology must land in; `Socx-Org` is where governance now lives.

## Related Documents

- Architecture: `CTX-010`, `DOM-010`
- Standards: `GEN-010`, `DOC-010`, `DOC-020`, `ENG-050`
- Current-State documentation: `REP-010`
- Reference Implementations: none
- Runbooks: none
- ADRs: `ADR-010` (the ADR practice this governance model includes), `ADR-030` (the philosophy behind how it is built)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
