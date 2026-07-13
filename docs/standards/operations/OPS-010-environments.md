---
id: OPS-010
title: Environments & Promotion
category: Operations
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs:
    - ADR-040
    - ADR-050
    - ADR-140
    - ADR-160
  reference:
    - reference/deployment
  templates: []
supersedes: []
superseded_by: null
---
# OPS-010 — Environments & Promotion

## Scope

Applies to the required environment tiers for every SOCX project and how a change moves between them. Does not cover the underlying infrastructure-as-code (see `OPS-020`) or release mechanics (see `OPS-030`).

## Rationale

A shared environment model lets anyone reason about "which environment is this bug in" and "what's the path to production" the same way across every project.

## Requirements

1. `OPS-010.1` — Every project MUST define at least two environment tiers: a non-production environment and production. A staging tier SHOULD be added once the project has external users depending on its uptime.
2. `OPS-010.2` — Each environment MUST be clearly identifiable at runtime (e.g. via an environment variable or visible banner) to prevent operator confusion.
3. `OPS-010.3` — A change MUST be deployed to and verified in a non-production environment before production, except for an emergency fix handled per the project's runbook.
4. `OPS-010.4` — Production environment configuration MUST NOT diverge from non-production in any way that isn't explicitly documented.
5. `OPS-010.5` — Each environment MUST have a named owner responsible for its health.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/deployment`
- ADR(s): `ADR-040`, `ADR-050`, `ADR-140`, `ADR-160`
- Template(s): none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
