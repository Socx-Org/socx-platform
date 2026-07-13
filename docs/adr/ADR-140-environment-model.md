---
id: ADR-140
title: Environment model
status: Draft
category: Operations
version: "0.1"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - INF-010
    - CTX-010
  standards:
    - OPS-010
  current_state:
    - CS-INF-010
  reference: []
  runbooks: []
  adrs:
    - ADR-040
    - ADR-050
supersedes: []
superseded_by: null
---

# ADR-140 — Environment model

## Context

A shared environment model lets anyone reason about "which environment is this bug in" and "what is the path to production" the same way across every project. `CS-INF-010` found **no non-production environment today** — one droplet appears to serve everything — which is a live `OPS-010.1` gap, not just an architectural one. This ADR settles the required environment shape.

## Decision

Every project has **at least two environment tiers** — a non-production environment and production — each a separate deployment target of the *same* topology (`ADR-050` / `INF-010`), differing only in scale and data. A change is verified in non-production before production, except for an emergency fix handled per the project's runbook. Each environment is identifiable at runtime and has a named owner. A **staging tier is added on demand**, once a project has external users depending on its uptime.

## Alternatives Considered

- **A single (production-only) environment** — Rejected: no safe place to verify a change before users see it. This is today's reality, not the target.
- **A fixed three-tier (dev / staging / prod) mandate for everything** — Rejected as over-prescriptive for small systems; staging is added when uptime actually matters, not by default.
- **Per-project bespoke environment models** — Rejected: defeats the platform-wide reasoning this decision exists to enable.

## Consequences

- `OPS-010` becomes a meaningful platform-wide rule with a concrete minimum.
- Today's single-droplet, single-environment reality (`CS-INF-010`) does not satisfy this — closing the gap is real infrastructure work and a candidate early runbook/reference.
- Environment tiers multiply the hosting footprint decided in `ADR-040`, and each tier is provisioned as code (`OPS-020` / `ADR-160`).

## Related Documents

- Architecture: `INF-010`, `CTX-010`
- Standards: `OPS-010`
- Current-State documentation: `CS-INF-010`
- Reference Implementations: none
- Runbooks: none yet
- ADRs: `ADR-040` (the hosting model each tier instantiates), `ADR-050` (the shared topology tiers share)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
