---
id: INF-010
title: Target Infrastructure Topology
category: Infrastructure
status: Approved
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - OPS-010
    - OPS-020
  adrs:
    - ADR-040
    - ADR-050
    - ADR-100
    - ADR-130
    - ADR-140
    - ADR-160
    - ADR-180
  reference:
    - reference/deployment
    - reference/nginx
    - reference/systemd
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# INF-010 — Target Infrastructure Topology

## Scope

The target hosting and networking shape of the platform, conceptually. This document MUST NOT contain deployment configuration, connection strings, ports, hostnames, or IP addresses — that detail belongs in `reference/` and each project's own deployment configuration, never here.

## Context

Every project needs to fit a known deployment shape rather than each inventing its own hosting arrangement — this is what lets `OPS-010` (environment tiers) and `OPS-020` (infrastructure as code) be meaningful platform-wide rules rather than per-project guesses.

## Target Design

```mermaid
flowchart TB
    internet(("Internet")) --> edge["Shared edge\n(nginx, platform-infra)"]
    edge --> svcA["Application process\n(systemd-managed)"]
    edge --> svcB["Application process\n(systemd-managed)"]
    edge --> svcC["Application process\n(systemd-managed)"]
```

Diagram source: `docs/diagrams/INF-010-target-infrastructure-topology.mmd`.

- A single shared edge (nginx, per `reference/nginx`) terminates all external traffic and routes to application processes — no application is directly internet-facing.
- Each application process is managed by systemd (per `reference/systemd`), not run ad hoc — this is what makes `OPS-030`'s rollback requirement and `OPS-040`'s health-check requirement mechanically achievable.
- Environment tiers (per `OPS-010`) are separate deployment targets of this same shape, not a variation on it — non-production and production both follow this topology, differing only in scale and data.
- All of the above is defined as code per `OPS-020`; this document explains *why* the shape looks like this, `reference/deployment` and each project's own deploy configuration hold the *how*.

## Current-State Gap

Not yet assessed.

## Related Documents

- Standards: `OPS-010`, `OPS-020`
- ADRs: `ADR-040`, `ADR-050`, `ADR-100`, `ADR-130`, `ADR-140`, `ADR-160`, `ADR-180`
- Reference Implementations: `reference/deployment`, `reference/nginx`, `reference/systemd` (all currently empty)
- Runbooks: none yet
- Current-State documentation: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
| 1.0 | 2026-07-13 | Approved | Socx |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
| 1.2 | 2026-07-15 | Added ADR-180 cross-reference | Socx |
