---
id: OPS-020
title: Infrastructure as Code
category: Operations
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs:
    - ADR-040
    - ADR-150
    - ADR-160
  reference:
    - reference/nginx
    - reference/systemd
    - reference/deployment
  templates:
    - templates/nginx
    - templates/systemd
supersedes: []
superseded_by: null
---
# OPS-020 — Infrastructure as Code

## Scope

Applies to how infrastructure and server configuration are defined and changed for every SOCX project. Does not cover application deployment/release mechanics (see `OPS-030`).

## Rationale

Undocumented manual changes to production infrastructure are one of the most common causes of unreproducible incidents and configuration drift.

## Requirements

1. `OPS-020.1` — All infrastructure configuration (nginx, systemd units, firewall rules, DNS, CI/CD config) MUST be defined as code, version-controlled, and reviewed via pull request — never edited manually on a live system as the source of truth.
2. `OPS-020.2` — A manual change made directly on a production system to resolve an emergency MUST be backported into version-controlled configuration within 24 hours, or before the next production deployment, whichever comes first.
3. `OPS-020.3` — Infrastructure configuration MUST start from the canonical templates in `reference/` for its domain (nginx, systemd, github) rather than being written from scratch per project.
4. `OPS-020.4` — A deviation from the canonical reference configuration MUST be documented in the project's own repository, with the reason.
5. `OPS-020.5` — Infrastructure changes MUST be applied through an idempotent, repeatable process (a script or tool), not a one-off sequence of manual commands.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/nginx`, `reference/systemd`, `reference/deployment`
- ADR(s): `ADR-040`, `ADR-150`, `ADR-160`
- Template(s): `templates/nginx`, `templates/systemd`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-12 | `OPS-020.2` now also requires backport before the next production deployment if that occurs within 24 hours | Socx |
| 1.2     | 2026-07-14 | Added ADR cross-references | Socx   |
