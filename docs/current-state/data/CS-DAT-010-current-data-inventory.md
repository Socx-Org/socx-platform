---
id: CS-DAT-010
title: Current Data Inventory
category: Data
status: Approved
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture:
    - DAT-010
  standards:
    - OPS-060
    - SEC-010
  adrs: []
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

| System          | Data store (observed)                                                                                               | Schema management                                                                                                                                                                   | Evidence                                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `ghs`         | PostgreSQL, accessed via raw`pg` driver (no ORM)                                                                  | Custom scripts:`db:create`, `db:migrate`, `db:seed` (`scripts/db/*.js`)                                                                                                     | Observed                                                                                                                         |
| `rms`         | PostgreSQL 16, accessed via Prisma                                                                                  | Prisma migrations (`packages/db`) **and** a set of hand-written raw SQL files (`infra/rms_001_initial_schema.sql` through `rms_005_super_admin_audit.sql`) both present | Observed — relationship between the two migration mechanisms (e.g. whether the raw SQL predates the Prisma adoption) is Unknown |
| `ams`         | PostgreSQL, via its own`packages/db` workspace (Prisma-style scripts: `db:migrate`, `db:seed`, `db:studio`) | Prisma-pattern migrations                                                                                                                                                           | Observed                                                                                                                         |
| `socx-org-uk` | No database dependency found in any of its three`apps/*/package.json` files                                       | None found                                                                                                                                                                          | Observed (absence)                                                                                                               |
| Redis           | Used by`ghs` (caching, per `.env.example`'s `CACHE_TTL_*` variables) and `ams` (job queue via BullMQ)       | N/A                                                                                                                                                                                 | Observed                                                                                                                         |

**Backup and retention:** `platform-infra` scaffolds `db-backup-daily@.timer` and `db-backup-hourly@.timer` systemd timers plus `backup-db.sh` / `restore-db.sh` scripts — but every one of these files is currently empty (see `CS-INF-010`). **No evidence of an actual, currently-running backup mechanism was found anywhere.** This is Unknown, not Observed-absent — it's possible backups run via a mechanism outside both repositories inspected (e.g. a DigitalOcean managed-database snapshot feature), but nothing in either repository set confirms or denies this.

**Retention:** no retention policy, for any data domain, was found documented anywhere in the four application repositories or in `platform-infra`.

## Gap vs. Target Architecture

| Aspect         | Current State                                                                                          | Target (`DAT-010`)                                                     | Difference                                                                         | Impact                                                                                                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Data ownership | Each system appears to own its own database (no evidence of cross-system DB access)                    | Exactly one owning system per data domain, no direct cross-system access | Directionally consistent, though unverified at the schema level                    | Encouraging, but not confirmed                                                                                                                                                                                                 |
| Backup         | Scaffolded (timer/script filenames exist) but**not implemented** — all relevant files are empty | `OPS-060` requires automated, tested backups with documented RPO/RTO   | A real, unresolved compliance gap against`OPS-060`, not just an architecture gap | **High** — if accurate, there is currently no confirmed backup mechanism for any of the platform's databases. This should be verified against the actual droplet as a priority, independent of any documentation effort |
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
