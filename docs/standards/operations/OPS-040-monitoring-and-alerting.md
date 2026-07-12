---
id: OPS-040
title: Monitoring & Alerting
category: Operations
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/monitoring
  templates: []
supersedes: []
superseded_by: null
---
# OPS-040 — Monitoring & Alerting

## Scope

Applies to the minimum observability required before a SOCX project goes live. Does not cover incident response procedure itself — that belongs in `docs/runbooks/` — and does not cover log format or content, which is `OPS-050`.

## Rationale

A project that can't tell you it's broken will be discovered broken by a user first. A minimum bar of health checks and alerting is cheaper than the incident it prevents.

## Requirements

1. `OPS-040.1` — Every production service MUST expose a health check endpoint or equivalent liveness signal.
2. `OPS-040.2` — Every production service MUST have monitoring configured to detect it being down or erroring, with an alert routed to a responsible owner.
3. `OPS-040.3` — Log format and content requirements are governed by `OPS-050` and MUST NOT be redefined here.
4. `OPS-040.4` — Every alert MUST link to, or be paired with, a runbook describing the response (see `DOC-010.2`).
5. `OPS-040.5` — An alert that fires without corresponding action for 3 consecutive occurrences MUST be reviewed and either adjusted or removed.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/monitoring`
- ADR(s): none yet
- Template(s): none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-12 | Removed duplicated log-format requirement from `OPS-040.3`; delegated to new `OPS-050` | Socx |
