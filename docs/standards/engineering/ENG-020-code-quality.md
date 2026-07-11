---
id: ENG-020
title: Code Quality & Review
category: Engineering
status: Approved
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
# ENG-020 — Code Quality & Review

## Scope

Applies to automated code-quality enforcement and the substance of pull request review for every SOCX project. Does not cover branch/PR mechanics (see `ENG-010`) or test requirements (see `ENG-030`).

## Rationale

A consistent quality bar, enforced automatically wherever possible, reduces defect rate and keeps review effort focused on things a machine can't check.

## Requirements

1. `ENG-020.1` — Every project MUST run an automated linter and formatter in CI; a pull request MUST NOT be mergeable if either check fails.
2. `ENG-020.2` — Formatting MUST be automatically enforced (auto-format on commit or CI check), not left to manual review comments.
3. `ENG-020.3` — Every pull request MUST receive at least one human review (mechanics governed by `ENG-010.5`); the reviewer MUST confirm the change matches its stated intent and includes tests where required by `ENG-030`.
4. `ENG-020.4` — Generated or vendored code MUST be excluded from linting and review-diff noise via appropriate ignore configuration.
5. `ENG-020.5` — A review comment that blocks a pull request MUST state the reason.
6. `ENG-020.6` — Code MUST NOT be merged with a TODO/FIXME marker describing a correctness gap unless it links to a tracked issue.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`.

## Related

- Reference implementation(s): `reference/github` (lint/format CI configuration, once populated)
- ADR(s): none yet
- Template(s): `templates/github`

## Revision History

| Version | Date       | Change   | Author |
| ------- | ---------- | -------- | ------ |
| 0.1     | 2026-07-11 | Approved | Socx   |
