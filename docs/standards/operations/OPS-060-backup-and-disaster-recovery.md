---
id: OPS-060
title: Backup & Disaster Recovery
category: Operations
status: Draft
applies_to: All SOCX projects
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/deployment
  templates: []
supersedes: []
superseded_by: null
---

# OPS-060 — Backup & Disaster Recovery

## Scope

Applies to backup and disaster recovery requirements for every SOCX project's persistent data and infrastructure. Does not cover release rollback (see `OPS-030`, which concerns application versions, not data).

## Rationale

A project without a tested backup is one incident away from unrecoverable data loss. Recovery expectations must be defined and rehearsed before an incident, not improvised during one.

## Requirements

1. `OPS-060.1` — Every project holding persistent data MUST have automated, scheduled backups of that data.
2. `OPS-060.2` — Backups MUST be stored in a location separate from the primary data store (a different host, account, or region) so a single failure cannot destroy both.
3. `OPS-060.3` — A backup restoration MUST be tested at least once per `review_cycle`, with the result recorded.
4. `OPS-060.4` — Every project MUST define and document a Recovery Point Objective (RPO) and a Recovery Time Objective (RTO) in its runbook.
5. `OPS-060.5` — A disaster recovery procedure MUST be documented in a Runbook (see `DOC-010.2`) and MUST NOT exist only as undocumented knowledge.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/deployment`
- ADR(s): none yet
- Template(s): none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-12 | Initial draft | Socx |
