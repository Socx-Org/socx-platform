---
id: TEC-010
title: Approved Technology Stack
category: Technology
status: Draft
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards: []
  adrs: []
  reference:
    - reference/nginx
    - reference/systemd
    - reference/github
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# TEC-010 — Approved Technology Stack

## Scope

The platform's approved technologies and the rationale for each, so a new project doesn't have to re-decide its stack from scratch. Does not restate how a technology is configured (see `reference/`) or why every individual choice was made in full (see the linked ADR per row) — this document is the current, living summary; ADRs are the immutable record of why.

## Context

Repeatedly re-deciding "what database," "what process manager," "what CI provider" per project is wasted effort and produces inconsistent operational tooling. A single approved list, kept current, removes that decision from every new project — and gives `DAT-010`, `INF-010`, `APP-010`, and `IAM-010` a common vocabulary to cite instead of each naming technologies independently.

**Open item:** the rows below reflect what can be inferred from this repository's existing structure (the `reference/` domains and related-repository naming) — they are not yet backed by an ADR and should be treated as proposed, not final, until confirmed and recorded.

## Target Design

| Layer | Approved technology | Status | ADR |
|---|---|---|---|
| Hosting | DigitalOcean droplet(s) | Proposed — inferred from `do-nginx-infra` naming | none yet |
| Reverse proxy / edge | nginx | Proposed — inferred from `reference/nginx` | none yet |
| Process management | systemd | Proposed — inferred from `reference/systemd` | none yet |
| CI/CD | GitHub Actions | Proposed — inferred from `reference/github` | none yet |
| Application language/framework | TBD — not yet confirmed | Undecided | none yet |
| Primary data store | TBD — not yet confirmed | Undecided | none yet |
| Identity provider | TBD — not yet confirmed | Undecided | none yet |

A row moves from `Proposed`/`Undecided` to `Approved` only once backed by an ADR recorded in `docs/adr/` (per `DOC-020`) — this table should never assert a technology is approved without a decision record behind it.

## Current-State Gap

Not yet assessed — this table describes an inferred, not confirmed, target; there is no `docs/current-state/` entry yet to compare it against.

## Related

- Standard(s) this design satisfies: none directly — this document informs other architecture documents rather than satisfying a standard itself
- ADR(s) behind this design: none yet
- Reference implementation(s): `reference/nginx`, `reference/systemd`, `reference/github` (all currently empty)
- Runbook(s): none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
