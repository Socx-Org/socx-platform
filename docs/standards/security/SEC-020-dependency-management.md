---
id: SEC-020
title: Dependency & Vulnerability Management
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
    - reference/github
  templates:
    - templates/github
supersedes: []
superseded_by: null
---
# SEC-020 — Dependency & Vulnerability Management

## Scope

Applies to third-party dependency sourcing and vulnerability scanning for every SOCX project. Does not cover internal code review (see `ENG-020`).

## Rationale

Most real-world breaches exploit known vulnerabilities in unpatched dependencies rather than novel code. A minimum scanning and patch cadence closes the most common gap.

## Requirements

1. `SEC-020.1` — Every project MUST run automated dependency vulnerability scanning in CI (e.g. `npm audit`, `pip-audit`, Dependabot, or the equivalent for its ecosystem).
2. `SEC-020.2` — A dependency with a known critical or high-severity vulnerability MUST NOT be introduced. An existing dependency that becomes vulnerable MUST be patched or replaced within 7 days (critical) or 30 days (high) of disclosure.
3. `SEC-020.3` — Dependencies MUST be sourced only from the ecosystem's official public registry or an approved internal mirror, never an unverified third-party URL.
4. `SEC-020.4` — Dependency versions MUST be pinned via a committed lockfile so builds are reproducible.
5. `SEC-020.5` — A dependency no longer used by the project MUST be removed, not left in the manifest.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github` (Dependabot/scanning configuration, once populated)
- ADR(s): none yet
- Template(s): `templates/github`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
