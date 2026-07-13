---
id: SEC-030
title: Access Control
category: Security
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs:
    - ADR-110
    - ADR-120
  reference:
    - reference/security
    - reference/github
  templates: []
supersedes: []
superseded_by: null
---
# SEC-030 — Access Control

## Scope

Applies to human and service access to repositories, infrastructure, and production systems. Does not cover application-level authentication/authorization for end users of a SOCX product — that is project-specific architecture.

## Rationale

Minimizing and auditing who can change what limits the blast radius of a compromised account or an honest mistake.

## Requirements

1. `SEC-030.1` — Access to production systems and secret stores MUST follow least privilege: granted only for the specific systems a person's role requires, not organization-wide by default.
2. `SEC-030.2` — Every account with access to production MUST have multi-factor authentication enabled.
3. `SEC-030.3` — Repository write access MUST be granted per-person or per-team, never via a shared or generic credential.
4. `SEC-030.4` — Access grants MUST be reviewed at least once per `review_cycle` (see `GEN-010.7`) and revoked promptly when no longer needed.
5. `SEC-030.5` — Administrative/owner-level access to a repository or infrastructure account MUST be limited to the minimum number of people needed for continuity.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/security`, `reference/github`
- ADR(s): `ADR-110`, `ADR-120`
- Template(s): none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
