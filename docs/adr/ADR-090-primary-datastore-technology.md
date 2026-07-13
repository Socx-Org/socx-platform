---
id: ADR-090
title: Primary datastore technology
status: Approved
category: Data
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - DAT-010
    - TEC-010
  standards:
    - OPS-060
    - SEC-010
  current_state:
    - CS-DAT-010
  reference: []
  runbooks: []
  adrs: []
supersedes: []
superseded_by: null
---

# ADR-090 — Primary datastore technology

## Context

`DAT-010` sets the single-writer data-ownership model but leaves the storage product to `TEC-010`, which lists "Primary data store" as `Under Evaluation`. As with the application stack, the current-state inventory shows this is already decided in practice.

Per `CS-DAT-010`:

- `ghs` — PostgreSQL via the raw `pg` driver (no ORM)
- `rms` — PostgreSQL 16 via Prisma
- `ams` — PostgreSQL via its own Prisma-style `packages/db`
- `socx-org-uk` — no database dependency found
- **Redis** — used by `ghs` (caching) and `ams` (BullMQ job queue)

The de-facto primary store is **PostgreSQL**, with **Redis** as a secondary cache/queue. The genuine open questions are whether to ratify that, whether to standardise the data-access layer (raw `pg` vs Prisma), and what role Redis holds. `CS-DAT-010` also raises a **high-impact, separate finding**: no running database backup mechanism could be confirmed — the `platform-infra` backup timers and scripts exist only as empty scaffold files. That is an `OPS-060` compliance gap to verify against the live droplet, independent of this decision.

## Decision

The platform adopts **PostgreSQL** as the approved primary relational datastore and **Redis** as the approved technology for caching and background-job queues. Specifically:

1. PostgreSQL is the system of record for relational data, making `TEC-010`'s row `Approved` and giving `DAT-010`'s ownership table a concrete storage technology.
2. Redis is a supporting store — cache and job queue — not a system of record, and so sits outside `DAT-010`'s single-writer ownership rules.
3. The data-access approach (standardise on **Prisma**, used by `rms` and `ams`, versus the raw `pg` driver in `ghs`, versus permitting both) is **deferred to a dedicated future ADR**, coupled with the language decision in `ADR-070`. This ADR settles the datastore, not the ORM.

## Alternatives Considered

- **Ratify PostgreSQL + Redis — selected.** Formalises what three of four applications already run; no migration cost for the system of record.
- **Adopt a different primary datastore** — Rejected as disproportionate: it would migrate multiple live databases with no evidenced driver.
- **Data-access sub-decision — Prisma vs raw `pg` vs both** — deferred to a dedicated future ADR. Prisma is the majority pattern and gives migrations and type-safety; raw `pg` gives control and fewer dependencies. Settling it does not block approving the datastore.
- **Leave the datastore "under evaluation"** — Rejected: it misrepresents reality and blocks `OPS-060` backup/RPO/RTO work, which cannot be specified against an undecided store.

## Consequences

- Ratifying PostgreSQL lets `DAT-010`'s per-domain retention/backup targets and `OPS-060`'s RPO/RTO requirements be written against a concrete technology.
- The unresolved backup gap in `CS-DAT-010` becomes actionable: with PostgreSQL now the confirmed store, the empty `platform-infra` backup scaffolding (or a DigitalOcean managed-snapshot alternative) must be implemented and tested to satisfy `OPS-060`. Approving this ADR settles the datastore only; it does **not** resolve the backup gap, which remains open and must be closed separately — approval must not be read as confirmation that backups exist.
- A data-access standard (if chosen) lets a single migration/tooling convention apply platform-wide; permitting both keeps `ghs` as a standing exception.
- Redis being named a supporting store, not a system of record, keeps it outside `DAT-010`'s single-writer ownership rules.

## Related Documents

- Architecture: `DAT-010`, `TEC-010`
- Standards: `OPS-060` (backup & disaster recovery), `SEC-010` (secrets — database credentials)
- Current-State documentation: `CS-DAT-010`
- Reference Implementations: none yet
- Runbooks: none yet — a backup/restore runbook is implied by the `OPS-060` gap
- ADRs: `ADR-070` (application language & framework, with which the ORM choice is coupled)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
