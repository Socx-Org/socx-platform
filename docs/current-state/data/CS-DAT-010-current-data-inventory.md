---
id: CS-DAT-010
title: Current Data Inventory
category: Data
status: Approved
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "2.0"
last_reviewed: 2026-07-15
review_cycle: quarterly
related:
  architecture:
    - DAT-010
  standards:
    - OPS-060
    - SEC-010
  adrs:
    - ADR-180
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---
# CS-DAT-010 — Current Data Inventory

## Scope

Actual data stores in use today and their actual (not target) retention/backup configuration. Does not restate the target ownership/lifecycle model (see `DAT-010`).

## Method

Read from each application's `package.json` dependencies, README, and (for `rms`) its committed SQL migration files and Prisma usage. No access to any live database — schema contents beyond filenames, actual row counts, and actual configured retention were not inspected.

## Inventory

**Platform transition (2026-07-15, `ADR-180`):** the droplet hosting all live databases has been decommissioned, and its data was **not migrated, snapshotted, or exported — it held no production data worth keeping** (test/development only, attested). The new host has no databases installed (`CS-INF-020`). The table below records each system's data store **as declared in its repository** — schema management and drivers as code, unchanged by the transition; no deployed instance of any of them currently exists.

| System          | Data store (observed)                                                                                               | Schema management                                                                                                                                                                   | Evidence                                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `ghs`         | PostgreSQL, accessed via raw`pg` driver (no ORM)                                                                  | Custom scripts:`db:create`, `db:migrate`, `db:seed` (`scripts/db/*.js`)                                                                                                     | Observed                                                                                                                         |
| `rms`         | PostgreSQL 16, accessed via Prisma                                                                                  | Prisma migrations (`packages/db`) **and** a set of hand-written raw SQL files (`infra/rms_001_initial_schema.sql` through `rms_005_super_admin_audit.sql`) both present | Observed — relationship between the two migration mechanisms (e.g. whether the raw SQL predates the Prisma adoption) is Unknown |
| `ams`         | PostgreSQL, via its own`packages/db` workspace (Prisma-style scripts: `db:migrate`, `db:seed`, `db:studio`) | Prisma-pattern migrations                                                                                                                                                           | Observed                                                                                                                         |
| `socx-org-uk` | No database dependency found in any of its three`apps/*/package.json` files                                       | None found                                                                                                                                                                          | Observed (absence)                                                                                                               |
| Redis           | Used by`ghs` (caching, per `.env.example`'s `CACHE_TTL_*` variables) and `ams` (job queue via BullMQ)       | N/A                                                                                                                                                                                 | Observed                                                                                                                         |

**Backup and retention:** definitively **none** — there are no databases and no data on the new host, so nothing is backed up and nothing is at risk (previously this was Unknown; the transition resolved it by removing the subject). The `platform-infra` empty backup scaffolds went down with the old droplet (`CS-INF-010`, Deprecated); their working replacements now exist as `reference/systemd`'s `db-backup@` units and timers, pending deployment. **`OPS-060.1` must be satisfied before the first production data is written** — the rebuild sequencing (Deliverable 6.2 before application deployment) enforces this ordering.

**Retention:** no retention policy, for any data domain, was found documented anywhere in the four application repositories or in `platform-infra`.

## Gap vs. Target Architecture

| Aspect         | Current State                                                                                          | Target (`DAT-010`)                                                     | Difference                                                                         | Impact                                                                                                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Data ownership | Each system appears to own its own database (no evidence of cross-system DB access)                    | Exactly one owning system per data domain, no direct cross-system access | Directionally consistent, though unverified at the schema level                    | Encouraging, but not confirmed                                                                                                                                                                                                 |
| Backup         | None — no databases exist yet on the new host (`ADR-180`) | `OPS-060` requires automated, tested backups with documented RPO/RTO   | Gap is now clean-slate rather than unknown-on-a-live-system | **Reframed** — no data is currently at risk; the obligation is sequencing, not remediation: `OPS-060.1` backups must be running before any production data is written (reference/systemd timers + reference/deployment script) |
| Retention      | Undocumented everywhere                                                                                | `DAT-010` expects a per-domain retention target                        | No retention target exists to compare against                                      | Cannot assess compliance until a target is set — recommend this be an early follow-up once`DAT-010`'s placeholder table is filled in                                                                                        |

## Related Documents

- Architecture: `DAT-010`
- Standards: `OPS-060`, `SEC-010`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
| 2.0     | 2026-07-15 | Platform transition (ADR-180): no live databases; legacy data not retained; backup gap reframed as sequencing obligation | Socx   |
