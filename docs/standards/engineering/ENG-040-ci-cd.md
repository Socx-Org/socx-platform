---
id: ENG-040
title: CI/CD Pipelines
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
    - reference/deployment
  templates:
    - templates/github
supersedes: []
superseded_by: null
---

# ENG-040 — CI/CD Pipelines

## Scope

Applies to the minimum required pipeline stages and merge/deploy gating for every SOCX project. Does not define deployment target specifics (see `OPS-020`, `OPS-030`).

## Rationale

A consistent pipeline shape lets any contributor reason about any project's build and release process without learning bespoke tooling per repository.

## Requirements

1. `ENG-040.1` — Every project MUST have a CI pipeline triggered on every pull request.
2. `ENG-040.2` — The pipeline MUST include, at minimum, dependency install, lint (`ENG-020.1`), test (`ENG-030.2`), and build stages, in that order, and MUST fail fast on the first failing stage.
3. `ENG-040.3` — Merge to `main` MUST require all pipeline stages to pass (enforced via the status-check requirement in `ENG-010.5`).
4. `ENG-040.4` — Deployment MUST be a separate pipeline stage/job from build/test, triggered only after merge to `main` or a release tag (see `OPS-030`), never from a feature branch.
5. `ENG-040.5` — Pipeline configuration MUST be version-controlled in the project repository, not configured only through a CI provider's UI.
6. `ENG-040.6` — Secrets used by the pipeline MUST be sourced from the CI provider's secret store (per `SEC-010`), never committed to pipeline configuration.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github`, `reference/deployment`
- ADR(s): none yet
- Template(s): `templates/github`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-11 | Initial draft | |
