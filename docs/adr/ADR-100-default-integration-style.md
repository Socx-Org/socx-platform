---
id: ADR-100
title: Default integration style
status: Draft
category: Integration
version: "0.1"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - INT-010
    - INF-010
  standards:
    - ENG-040
  current_state:
    - CS-INT-010
  reference: []
  runbooks: []
  adrs:
    - ADR-050
    - ADR-080
supersedes: []
superseded_by: null
---

# ADR-100 — Default integration style

## Context

Ad hoc point-to-point integration — each pair of systems inventing its own protocol — becomes expensive to secure and reason about as systems multiply. `CS-INT-010` found that **no cross-system calls exist today**: the applications are integration-independent behind the shared edge, and only `rms` publishes a versioned OpenAPI spec. So this ADR sets the default *before* integration starts, rather than to fix an existing tangle.

## Decision

The default integration style is **synchronous HTTPS routed through the shared edge** (`ADR-050` / `INF-010`), not direct system-to-system network access. Endpoints one system exposes for another are **versioned** (in path or header), and a breaking change ships as a new version rather than an in-place change, so consumers are not forced to upgrade in lockstep. Systems never integrate by reading each other's datastores (`ADR-080`). **Asynchronous / event-driven integration is out of scope** until a concrete use case needs it, at which point it is recorded as a new ADR rather than added quietly.

## Alternatives Considered

- **Direct system-to-system calls / a private internal mesh** — Rejected: an invisible integration surface that is harder to secure than traffic routed through the edge.
- **Event-driven / asynchronous as the default now** — Rejected (YAGNI): nothing integrates today, so a broker and its operational surface would be premature.
- **Shared-database integration** — Rejected: violates `ADR-080`'s ownership rule.

## Consequences

- All integration remains visible in one place (the edge).
- Versioned contracts mean consumers are not forced to upgrade in lockstep with providers.
- Contract discipline is currently uneven — per `CS-INT-010`, only `rms` has a spec — so when cross-system calls begin, `ghs`, `socx-org-uk`, and `ams` need contract work first.
- Adopting asynchronous integration later is a deliberate, recorded decision, not a silent addition.

## Related Documents

- Architecture: `INT-010`, `INF-010`
- Standards: `ENG-040`
- Current-State documentation: `CS-INT-010`
- Reference Implementations: none
- Runbooks: none
- ADRs: `ADR-050` (the edge integration is routed through), `ADR-080` (why not via shared databases)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
