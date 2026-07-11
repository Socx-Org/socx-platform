---
id: SEC-010
title: Secrets Management
category: Security
status: Draft
applies_to: All SOCX projects
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/security
  templates:
    - templates/systemd
supersedes: []
superseded_by: null
---
# SEC-010 — Secrets Management

## Scope

Applies to how credentials, tokens, and keys are stored and consumed by every SOCX project. Does not cover access control for human accounts (see `SEC-030`).

## Rationale

Leaked secrets are one of the highest-impact, most preventable causes of incidents. A uniform baseline avoids each project inventing its own, often weaker, handling.

## Requirements

1. `SEC-010.1` — Secrets MUST NOT be committed to any repository, including in commit history, examples, or test fixtures.
2. `SEC-010.2` — Every project MUST ignore local secret files (e.g. `.env`) from repository creation, not added reactively after a leak.
3. `SEC-010.3` — Production secrets MUST be sourced from a dedicated secret store or the deployment platform's secret mechanism (CI provider secrets, systemd credentials, environment injected at deploy time) — never hardcoded.
4. `SEC-010.4` — A secret known or suspected to have been exposed MUST be rotated immediately, and the exposure MUST be recorded in the project's runbook.
5. `SEC-010.5` — Secrets MUST NOT be logged, including in CI output, application logs, or error messages.
6. `SEC-010.6` — Access to production secrets SHOULD be limited to the minimum set of people and systems that require it (see `SEC-030`).

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/security`
- ADR(s): none yet
- Template(s): `templates/systemd` (credential handling)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
