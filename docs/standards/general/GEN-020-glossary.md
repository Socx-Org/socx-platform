---
id: GEN-020
title: Glossary
category: General
status: Draft
applies_to: All SOCX projects
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
  reference: []
  templates: []
supersedes: []
superseded_by: null
---

# GEN-020 — Glossary

## Scope

Defines terminology used consistently across the Engineering Standards Handbook. Applies to every standard in `docs/standards/`. Does not define terminology specific to a single project's own domain — that belongs in that project's own documentation.

## Rationale

Standards written independently over time tend to redefine the same term slightly differently (e.g. what counts as an "environment," or when something is "canonical"). A single glossary prevents that drift and gives every standard a shared vocabulary to cite instead of re-explaining.

## Requirements

1. `GEN-020.1` — Every standard MUST use terms as defined in this glossary rather than defining its own variant.
2. `GEN-020.2` — A standard that introduces a term used by more than one standard MUST add it to this glossary rather than defining it locally.
3. `GEN-020.3` — A term defined here MUST NOT be redefined, or used with a different meaning, in another standard.

## Definitions

| Term | Definition |
|---|---|
| MUST / SHOULD / MAY | Used per RFC 2119: MUST is an absolute requirement, SHOULD is a strong recommendation that may be departed from with justification, MAY is optional. |
| Project | A SOCX application repository (e.g. `socx-org-uk`, `ghs`, `rms`) subject to this handbook, as distinct from this repository (`socx-platform`) itself. |
| Environment | A distinct, isolated deployment target for a project (e.g. non-production, staging, production) — see `OPS-010`. |
| Canonical | The single authoritative version of a configuration or implementation, maintained in `reference/` and not duplicated elsewhere. |
| Reference Implementation | A working, approved example of a standard's requirements, kept in `reference/` — see the handbook's Separation of Concerns. |
| Exception | A documented, time-boxed deviation from a specific requirement, recorded per `GEN-010.9`. |
| Deprecated | A standard that has been superseded but is retained, unmodified, for historical reference — see `GEN-010.8`. |

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): none
- ADR(s): none yet
- Template(s): none

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-12 | Initial draft | Socx |
