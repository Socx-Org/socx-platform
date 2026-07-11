---
id: ENG-030
title: Testing
category: Engineering
status: Draft
applies_to: All SOCX projects
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/github
  templates:
    - templates/github
supersedes: []
superseded_by: null
---

# ENG-030 — Testing

## Scope

Applies to the minimum automated testing every SOCX project must have and the merge gate it forms. Does not mandate a specific test framework per language.

## Rationale

Automated tests are the primary defense against regressions across a growing set of independently deployed projects, and the cheapest point to catch a defect.

## Requirements

1. `ENG-030.1` — Every project MUST have an automated test suite runnable in CI.
2. `ENG-030.2` — A pull request MUST NOT be mergeable if the test suite fails.
3. `ENG-030.3` — Every project MUST include unit tests for its business logic, and integration tests wherever it integrates with an external system (database, third-party API, message queue).
4. `ENG-030.4` — Integration tests MUST run against a real or realistic instance of the external dependency (e.g. a containerized database) rather than a mock, whenever feasible.
5. `ENG-030.5` — A bug fix MUST include a regression test that reproduces the defect before the fix, unless technically infeasible — in which case this MUST be recorded as an exception per `GEN-010.9`.
6. `ENG-030.6` — The test suite MUST be runnable locally with a single command, not only inside CI.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github` (CI test stage, once populated)
- ADR(s): none yet
- Template(s): `templates/github`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-11 | Initial draft | |
