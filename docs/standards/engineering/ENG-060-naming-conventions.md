---
id: ENG-060
title: Naming Conventions
category: Engineering
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
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

## Requirements

1. `ENG-060.1` — A project repository name MUST be lowercase, kebab-case, and MUST NOT include an environment or version suffix (e.g. `ghs`, not `ghs-prod` or `ghs-v2`).
2. `ENG-060.2` — Branch and commit naming is governed by `ENG-010.3`–`ENG-010.4` and MUST NOT be redefined here.
3. `ENG-060.3` — Environment variable names MUST be `UPPER_SNAKE_CASE` and MUST be prefixed with the project name where the variable is not already scoped by a container or service boundary (e.g. `GHS_DATABASE_URL`).
4. `ENG-060.4` — Infrastructure resource names (servers, services, systemd units) MUST include the project name and environment, in the form `<project>-<environment>-<resource>` (e.g. `ghs-prod-api`).
5. `ENG-060.5` — A name assigned to a production resource MUST NOT be reused for a different resource after decommissioning, to avoid ambiguity in historical logs and monitoring.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/systemd`, `reference/nginx`
- ADR(s): none yet
- Template(s): `templates/systemd`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-12 | Initial draft | Socx   |
| 1.0     | 2026-07-12 | Approved      | Socx   |
