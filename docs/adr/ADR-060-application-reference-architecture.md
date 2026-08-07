---
id: ADR-060
title: Three-layer application reference architecture
status: Approved
category: Application
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - APP-010
  standards:
    - ENG-050
    - ENG-060
    - SEC-010
    - OPS-050
  current_state:
    - CS-APP-010
  reference: []
  runbooks: []
  adrs:
    - ADR-070
    - ADR-080
    - ADR-130
supersedes: []
superseded_by: null
---

# ADR-060 — Three-layer application reference architecture

## Context

Without a shared internal structure, each application invents its own layering, its own place for configuration, and its own way of wiring in logging and secrets — which then has to be relearned per project. `CS-APP-010` found real, organic convergence already underway: all four applications use an `apps/{api,web,worker}` split, and three of the four additionally extract shared code into `packages/*`. It also notes that actual in-`src/` code-level layering was not inspected. `APP-010` defines the target three-layer pattern; this ADR records the decision to standardise on it.

## Decision

Every SOCX application targets **three internal layers**, regardless of language or framework:

1. **Interface layer** — transport, request/response shape, and input validation; talks only to the application layer, never directly to persistence.
2. **Application layer** — business logic and orchestration; no transport- or framework-specific code, so it is testable without the interface layer.
3. **Data-access layer** — the only layer permitted to touch persistence (per `ADR-080` / `DAT-010`), exposing a narrow interface upward.

Cross-cutting concerns are wired at layer edges, not scattered: configuration and secrets are read once at startup (per `ADR-130` / `SEC-010`) and passed down; logging is structured (per `OPS-050`) and emitted at each layer boundary. On disk this maps to `ENG-050`'s `src/` / `tests/` / `deploy/` split.

## Alternatives Considered

- **No prescribed internal structure** — Rejected: forfeits the mechanical checkability of `ENG-050`/`ENG-060` and the contributor mobility `APP-010` exists to create.
- **A heavier layering (full hexagonal / ports-and-adapters everywhere)** — Rejected as over-engineering for the platform's size; the three-layer pattern is the floor, not a ceiling an application may not exceed when justified.
- **Let each framework's conventions dictate structure** — Rejected: produces the per-app idiosyncrasy the platform is trying to remove.

## Consequences

- `ENG-050`/`ENG-060` become mechanically checkable and a contributor can move between applications without re-deriving each one's layout.
- `socx-org-uk` (no `packages/` split, per `CS-APP-010`) is the current outlier; conformance is retrofit work. Because code-level layering was not inspected, this ADR sets the target — it does not certify current compliance.
- The "data-access layer only touches persistence" rule is what makes `ADR-080`'s single-writer ownership enforceable in code.

## Related Documents

- Architecture: `APP-010`
- Standards: `ENG-050`, `ENG-060`, `SEC-010`, `OPS-050`
- Current-State documentation: `CS-APP-010`
- Reference Implementations: `reference/application` (Approved, verified on-host 2026-08-07 — the canonical three-layer service this ADR anticipated)
- Runbooks: none
- ADRs: `ADR-070` (the stack the layers are built in), `ADR-080` (data ownership enforced at the data-access layer), `ADR-130` (startup secret loading)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
