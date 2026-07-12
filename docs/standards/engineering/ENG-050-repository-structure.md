---
id: ENG-050
title: Repository Structure
category: Engineering
status: Draft
applies_to: All SOCX projects
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/deployment
  templates:
    - templates/github
supersedes: []
superseded_by: null
---

# ENG-050 — Repository Structure

## Scope

Applies to the minimum required top-level structure for every SOCX project repository. Does not cover this handbook's own repository structure, which is set by the project charter. Does not cover secrets handling (see `SEC-010`) or how infrastructure changes are made (see `OPS-020`).

## Rationale

A consistent repository layout lets shared tooling (CI templates, onboarding scripts) work the same way across every project, and lets any contributor navigate an unfamiliar project without a guided tour.

## Requirements

1. `ENG-050.1` — Every project repository MUST have, at its root, a README, a `LICENSE`, a `.gitignore`, and CI pipeline configuration (per `ENG-040.5`).
2. `ENG-050.2` — Source code MUST live under a single top-level directory dedicated to it (e.g. `src/`), separate from configuration, scripts, and tests.
3. `ENG-050.3` — Automated tests MUST live in a single, clearly named location (e.g. `tests/`, or co-located per the language ecosystem's own convention), not scattered ad hoc across the repository.
4. `ENG-050.4` — Infrastructure or deployment configuration specific to the project MUST live in a dedicated top-level directory (e.g. `deploy/` or `infra/`), separate from application source.
5. `ENG-050.5` — Build output, dependency caches, and IDE-specific files MUST NOT be committed, and MUST be excluded via `.gitignore`.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/deployment`
- ADR(s): none yet
- Template(s): `templates/github`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-12 | Initial draft | Socx |
