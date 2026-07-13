---
id: DAT-010
title: Platform Data Architecture
category: Data
status: Draft
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - OPS-060
    - SEC-010
  adrs: []
  reference:
    - reference/deployment
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# DAT-010 — Platform Data Architecture

## Scope

Data ownership, cross-system flow, persistence strategy, lifecycle (creation through archival/deletion), and target retention and backup strategy for data across SOCX systems. Does not restate which storage product implements persistence (see `TEC-010`) or the operational backup/restore requirements every project MUST meet (see `OPS-060`) — this document describes the target design that satisfies them.

## Context

With multiple systems (`socx-org-uk`, `ghs`, `rms`), the platform's biggest data risk isn't losing data — it's two systems each becoming a source of truth for the same thing. This document exists to assign ownership explicitly before that happens, and to give every system a consistent lifecycle/retention/backup pattern instead of each inventing its own.

**Open item:** actual data domains and their owning system are not yet confirmed — the table below is a placeholder to be filled in as `DOM-010`'s system responsibilities are confirmed.

## Target Design

**Ownership.** Each data domain has exactly one owning system, which is the only system permitted to write it. Other systems that need it read it via `INT-010`'s integration conventions, not by connecting directly to another system's data store.

| Data domain | Owning system | Consumers | Retention target | Backup approach |
|---|---|---|---|---|
| TBD — confirm | TBD | TBD | TBD | Per `OPS-060` |

**Lifecycle.** Data moves through four stages, each of which should be identifiable for any given data domain once the table above is filled in:

1. **Creation** — written only by the owning system.
2. **Propagation** — shared to consuming systems via the mechanism defined in `INT-010`, never via direct cross-system database access.
3. **Retention** — held per the retention target above; the target itself is set per data domain, not platform-wide, since a support ticket and a financial record don't share a retention need.
4. **Archival / deletion** — the owning system is responsible for enforcing its own retention target; this is not a shared platform job.

**Backup.** Every persistent store falls under `OPS-060` (automated, tested backups; documented RPO/RTO). This document's job is to name, per data domain, what the target RPO/RTO actually is — that detail belongs here (the design), while `OPS-060` mandates that it exists and gets tested (the rule).

## Current-State Gap

Not yet assessed.

## Related

- Standard(s) this design satisfies: `OPS-060`, `SEC-010`
- ADR(s) behind this design: none yet
- Reference implementation(s): `reference/deployment` (currently empty)
- Runbook(s): none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
