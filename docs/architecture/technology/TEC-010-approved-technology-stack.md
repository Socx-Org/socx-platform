---
id: TEC-010
title: Approved Technology Stack
category: Technology
status: Approved
owner: Platform Engineering
version: "1.0"
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

## Technology Lifecycle

Every row in the table below carries exactly one of four statuses:

| Status | Meaning |
|---|---|
| `Proposed` | A candidate target technology, not yet backed by an ADR |
| `Under Evaluation` | Actively being assessed; no direction chosen yet |
| `Approved` | Backed by an ADR; safe to build against |
| `Deprecated` | Previously Approved, now being phased out — see the superseding ADR |

## Target Design

| Layer | Technology | Status | Notes | ADR |
|---|---|---|---|---|
| Hosting | DigitalOcean droplet(s) | Proposed | Inferred from `platform-infra` repository naming | none yet |
| Reverse proxy / edge | nginx | Proposed | Inferred from `reference/nginx` | none yet |
| Process management | systemd | Proposed | Inferred from `reference/systemd` | none yet |
| CI/CD | GitHub Actions | Proposed | Inferred from `reference/github` | none yet |
| Application language/framework | Not yet identified | Under Evaluation | No signal yet in this repository or its related repositories | none yet |
| Primary data store | Not yet identified | Under Evaluation | No signal yet | none yet |
| Identity provider | Not yet identified | Under Evaluation | Tied to the open per-system vs. SSO decision in `IAM-010` | none yet |

A row moves to `Approved` only once backed by an ADR recorded in `docs/adr/` (per `DOC-020`) — this table should never assert a technology is `Approved` without a decision record behind it.

## Current-State Gap

Not yet assessed — this table describes an inferred, not confirmed, target; there is no `docs/current-state/` entry yet to compare it against.

## Related Documents

- Standards: none directly — this document informs other architecture documents rather than satisfying a standard itself
- ADRs: none yet
- Reference Implementations: `reference/nginx`, `reference/systemd`, `reference/github` (all currently empty)
- Runbooks: none yet
- Current-State documentation: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
| 1.0 | 2026-07-13 | Approved | Socx |
