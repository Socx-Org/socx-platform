---
id: DOC-020
title: ADR Usage Criteria
category: Documentation
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs:
    - ADR-010
    - ADR-020
  reference: []
  templates:
    - templates/adr
supersedes: []
superseded_by: null
---
# DOC-020 — ADR Usage Criteria

## Scope

Applies to when an Architecture Decision Record is mandatory versus optional for every SOCX project. Does not define ADR format — see `templates/adr`.

## Rationale

Without a clear bar, ADRs either get written for every trivial choice (noise) or skipped for decisions that need a durable record — the gap this repository exists to close.

## Requirements

1. `DOC-020.1` — An ADR MUST be written for any decision that is expensive to reverse (e.g. choice of database, hosting provider, core framework, authentication mechanism).
2. `DOC-020.2` — An ADR MUST be written when a project deviates from a handbook standard as a permanent architectural choice, as distinct from a time-boxed exception (see `GEN-010.9`).
3. `DOC-020.3` — An ADR MUST NOT be written for reversible, low-cost implementation details (e.g. variable naming, internal function structure) — those belong in code review, not the ADR log.
4. `DOC-020.4` — An ADR MUST use the template at `templates/adr` and MUST be added to the relevant project's `docs/adr/` (or this repository's, if the decision is platform-wide).
5. `DOC-020.5` — An accepted ADR MUST NOT be edited to reflect a later reversal. A reversal MUST be recorded as a new ADR that supersedes the old one, preserving history.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): none
- ADR(s): `ADR-010`, `ADR-020`
- Template(s): `templates/adr`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |
