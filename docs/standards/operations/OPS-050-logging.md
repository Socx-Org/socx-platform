---
id: OPS-050
title: Logging
category: Operations
status: Aproved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs:
    - ADR-060
  reference:
    - reference/monitoring
  templates: []
supersedes: []
superseded_by: null
---
# OPS-050 — Logging

## Scope

Applies to the format and content of logs produced by every SOCX project, in every environment. Does not cover alert routing or health checks (see `OPS-040`). Does not redefine secrets handling (see `SEC-010`).

## Rationale

Logs are the primary evidence available during an incident. Inconsistent or unstructured logs across projects slow down diagnosis precisely when speed matters most.

## Requirements

1. `OPS-050.1` — Every project MUST emit logs in a structured format (e.g. JSON) rather than unstructured free text, in every environment including non-production.
2. `OPS-050.2` — Every log entry MUST include, at minimum, a timestamp in UTC, a severity level, and the originating service or project name.
3. `OPS-050.3` — Logs MUST NOT contain secrets, per `SEC-010.5`.
4. `OPS-050.4` — Logs MUST NOT contain unredacted personal data beyond what is strictly required for debugging; where personal data is logged, this MUST be identified in the project's documentation.
5. `OPS-050.5` — Log retention MUST be explicitly configured, not left at a provider's undocumented default, and MUST be documented in the project's runbook.
6. `OPS-050.6` — Logs MUST be centrally aggregated, not left only on local disk on the originating host, so they remain accessible after the host is replaced or terminated.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/monitoring`
- ADR(s): `ADR-060`
- Template(s): none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-12 | Initial draft | Socx   |
| 1.0     | 2026-07-12 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
