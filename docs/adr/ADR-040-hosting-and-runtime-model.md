---
id: ADR-040
title: Hosting & process-runtime model
status: Approved
category: Infrastructure
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - INF-010
    - TEC-010
  standards:
    - OPS-010
    - OPS-020
    - OPS-030
    - OPS-040
  current_state:
    - CS-INF-010
    - CS-TEC-010
  reference:
    - reference/systemd
    - reference/deployment
  runbooks: []
  adrs:
    - ADR-050
    - ADR-130
    - ADR-160
    - ADR-150
supersedes: []
superseded_by: null
---

# ADR-040 — Hosting & process-runtime model

## Context

The platform needs one committed answer to "what do we run services on, and how are processes supervised," so that `OPS-010`/`020`/`030`/`040` can be platform-wide rules rather than per-project guesses. `CS-INF-010` and `CS-TEC-010` show today's reality: a single DigitalOcean droplet (Ubuntu 24.04), an nginx edge, and systemd-managed Node processes — but the systemd units are `nvm`-wrapped via `bash -lc` (fragile: fails if `$HOME` or the Node version don't resolve in the systemd context), and the clean redesign exists only as empty scaffold files. No container runtime or orchestration is in use.

## Decision

The platform adopts a **self-managed hosting and runtime model**: DigitalOcean droplet(s) running application processes **directly under systemd**, behind the shared nginx edge (`ADR-050`). Container orchestration is explicitly **not** adopted at the current scale. Direct-execution systemd units — removing the `nvm` wrapping that `CS-INF-010` flagged as fragile — are adopted as part of this decision. This is revisited if scale, team size, or the environment count (`ADR-140`) grows.

## Alternatives Considered

- **Self-managed droplet + systemd, no orchestration — selected.** Matches reality; lowest operational surface; direct-execution units remove the known `nvm` startup fragility. Cost accepted: single-host thinking and in-house responsibility for patching and backups.
- **Containers + orchestration (Docker + Kubernetes / Nomad)** — stronger isolation and horizontal scale, but large operational overhead for four modest systems on one droplet; premature.
- **Managed PaaS (e.g. DigitalOcean App Platform)** — offloads process/runtime management, but re-platforms every application and reduces control; a bigger migration than the current problem warrants.

## Consequences

- Confirms the substrate that `OPS-020` (IaC, `ADR-160`), `OPS-030` (release/rollback), and `OPS-040` (health checks) build on.
- systemd credentials (`ADR-130`) and the systemd-managed local-port model (`ADR-050`) depend on this choice.
- Self-managed keeps operational responsibility in-house, which raises the stakes of the unresolved `OPS-060` backup gap (`CS-DAT-010`).
- A future move to containers or PaaS would supersede this ADR and several that depend on it (`ADR-050`, `ADR-130`).

## Related Documents

- Architecture: `INF-010`, `TEC-010`
- Standards: `OPS-010`, `OPS-020`, `OPS-030`, `OPS-040`
- Current-State documentation: `CS-INF-010`, `CS-TEC-010`
- Reference Implementations: `reference/systemd`, `reference/deployment`
- Runbooks: none yet — deploy and rollback runbooks depend on this decision
- ADRs: `ADR-050`, `ADR-130`, `ADR-160`, `ADR-150`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
