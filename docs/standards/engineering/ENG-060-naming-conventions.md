---
id: ENG-060
title: Naming Conventions
category: Engineering
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-08-08
review_cycle: annual
related:
  adrs:
    - ADR-060
  standards:
    - OPS-010
  reference:
    - reference/systemd
    - reference/nginx
  templates:
    - templates/systemd
supersedes: []
superseded_by: null
---
# ENG-060 — Naming Conventions

## Scope

Applies to naming for repositories, environment variables, and infrastructure resources. Branch and commit naming is governed by `ENG-010` and is not redefined here. Does not cover code-level identifier style within a language — that is a linter/style-guide concern under `ENG-020`.

## Rationale

Predictable naming lets tooling and people locate or provision a repository, variable, or resource without checking documentation first, and avoids collisions as projects multiply across environments.

`ENG-060.4`'s environment segment specifically exists to prevent resource-name collisions once a project has more than one environment tier — a real, forward-looking concern, but one with nothing to disambiguate yet where only one tier exists (`ADR-180`'s `OPS-010.1` exception, still open as of this writing). Requiring it universally from day one would mean every resource name carries a single, unvarying, purely decorative segment — found during RMS's Phase 2A discovery (2026-08-08), where `reference/systemd`'s own template doesn't include one either. Conditioning the requirement on `OPS-010.1` preserves the real intent without forcing that.

## Requirements

1. `ENG-060.1` — A project repository name MUST be lowercase, kebab-case, and MUST NOT include an environment or version suffix (e.g. `ghs`, not `ghs-prod` or `ghs-v2`).
2. `ENG-060.2` — Branch and commit naming is governed by `ENG-010.3`–`ENG-010.4` and MUST NOT be redefined here.
3. `ENG-060.3` — Environment variable names MUST be `UPPER_SNAKE_CASE` and MUST be prefixed with the project name where the variable is not already scoped by a container or service boundary (e.g. `GHS_DATABASE_URL`).
4. `ENG-060.4` — Once a project has more than one environment tier (`OPS-010.1`), infrastructure resource names (servers, services, systemd units) MUST include the project name and environment, in the form `<project>-<environment>-<resource>` (e.g. `ghs-prod-api`). While a project has exactly one environment tier, the environment segment is OPTIONAL: a single, unvarying value disambiguates nothing yet, and `OPS-010.2`'s runtime-identifiability requirement (e.g. `SOCX_ENV=`, an `X-SOCX-Environment` response header) already covers operator-facing environment identification in the meantime.
5. `ENG-060.5` — A name assigned to a production resource MUST NOT be reused for a different resource after decommissioning, to avoid ambiguity in historical logs and monitoring.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/systemd`, `reference/nginx`, `reference/application`
- ADR(s): `ADR-060`
- Template(s): `templates/systemd`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-12 | Initial draft | Socx   |
| 1.0     | 2026-07-12 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
| 1.2     | 2026-08-08 | `ENG-060.4`'s environment segment now conditional on `OPS-010.1` (more than one environment tier actually existing) — found inconsistent with `reference/systemd`'s own template during RMS Phase 2A discovery; resolved via `socx-platform#89` rather than migrating live resources to satisfy a decorative segment | Socx |
