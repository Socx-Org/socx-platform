---
id: OPS-030
title: Release & Rollback
category: Operations
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-12
review_cycle: annual
related:
  adrs: []
  reference:
    - reference/deployment
  templates: []
supersedes: []
superseded_by: null
---
# OPS-030 — Release & Rollback

## Scope

Applies to how a build becomes a versioned release and how it is rolled back for every SOCX project. Does not cover environment topology (see `OPS-010`) or the underlying infrastructure (see `OPS-020`).

## Rationale

A fast, well-understood rollback path is the single biggest lever for limiting the impact of a bad release.

## Requirements

1. `OPS-030.1` — Every deployable artifact MUST be versioned using Semantic Versioning.
2. `OPS-030.2` — A production deployment MUST be traceable to an exact commit or tag; deploying an unversioned or "latest" artifact to production MUST NOT be done.
3. `OPS-030.3` — Every project MUST have a rollback procedure, documented in a Runbook (see `DOC-010.2`), capable of restoring the previous version without a full redeploy cycle from scratch.
4. `OPS-030.4` — The rollback procedure MUST be exercised, not just written, at least once per `review_cycle`.
5. `OPS-030.5` — Deployment to production MUST require explicit approval or an automated gate (a passing pipeline per `ENG-040.3`) — never an unreviewed push.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/deployment`
- ADR(s): none yet
- Template(s): none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-11 | Initial draft | Socx   |
| 1.0     | 2026-07-11 | Approved      | Socx   |
| 1.1     | 2026-07-12 | `OPS-030.3` now requires the rollback procedure to be documented in a Runbook specifically, not just "documented" | Socx |
