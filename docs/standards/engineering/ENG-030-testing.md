---
id: ENG-030
title: Testing
category: Engineering
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs:
    - ADR-070
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
4. `ENG-030.4` — Integration tests MUST run against a real or containerized instance of the external dependency rather than a mock, except where the dependency cannot be instantiated in a CI environment (e.g. a third-party SaaS API with no sandbox or test mode) — in which case a mock MUST be paired with a contract test verified against the real dependency at least once per `review_cycle`.
5. `ENG-030.5` — A bug fix MUST include a regression test that reproduces the defect before the fix is applied. If the defect cannot be triggered outside a production-only condition (e.g. dependent on live third-party state unavailable in any test environment), this MUST be recorded as an exception per `GEN-010.9`, citing the specific blocking condition.
6. `ENG-030.6` — The test suite MUST be runnable locally with a single command, not only inside CI.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github` (CI test stage), `reference/application` (real unit + real-database integration tests, verified on-host 2026-08-07)
- ADR(s): `ADR-070`
- Template(s): `templates/github`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-12 | Replaced subjective "whenever feasible" / "technically infeasible" wording in `ENG-030.4`–`.5` with objective, auditable criteria | Socx |
| 1.2     | 2026-07-14 | Added ADR cross-references | Socx   |
