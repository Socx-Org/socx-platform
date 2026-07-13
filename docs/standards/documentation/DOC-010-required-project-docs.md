---
id: DOC-010
title: Required Project Documentation
category: Documentation
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs:
    - ADR-020
    - ADR-030
  reference: []
  templates:
    - templates/runbooks
supersedes: []
superseded_by: null
---
# DOC-010 — Required Project Documentation

## Scope

Applies to the minimum documentation every SOCX project repository must contain. Does not define documentation standards for this handbook's own repository — that's set by the project charter.

## Rationale

A consistent minimum bar of documentation means anyone can onboard to any SOCX project, or hand off an incident, without hunting for missing context.

## Requirements

1. `DOC-010.1` — Every project repository MUST have a README describing its purpose, how to run it locally, and how to deploy it (or a link to the runbook that does).
2. `DOC-010.2` — Every project MUST have at least one runbook covering its most likely failure mode.
3. `DOC-010.3` — Every project MUST document its environment variables and required configuration, and what each one is for.
4. `DOC-010.4` — Every project MUST name an owner (person or team) in its README.
5. `DOC-010.5` — Documentation MUST be updated in the same pull request as the change it describes, not deferred as follow-up work.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): none
- ADR(s): `ADR-020`, `ADR-030`
- Template(s): `templates/runbooks`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
