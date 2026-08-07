---
id: TEC-010
title: Approved Technology Stack
category: Technology
status: Approved
owner: Platform Engineering
version: "1.5"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards: []
  adrs:
    - ADR-040
    - ADR-050
    - ADR-070
    - ADR-090
    - ADR-120
    - ADR-150
    - ADR-160
    - ADR-180
  reference:
    - reference/nginx
    - reference/systemd
    - reference/github
  runbooks: []
  current_state:
    - CS-TEC-010
supersedes: []
superseded_by: null
---

# TEC-010 — Approved Technology Stack

## Scope

The platform's approved technologies and the rationale for each, so a new project doesn't have to re-decide its stack from scratch. Does not restate how a technology is configured (see `reference/`) or why every individual choice was made in full (see the linked ADR per row) — this document is the current, living summary; ADRs are the immutable record of why.

## Context

Repeatedly re-deciding "what database," "what process manager," "what CI provider" per project is wasted effort and produces inconsistent operational tooling. A single approved list, kept current, removes that decision from every new project — and gives `DAT-010`, `INF-010`, `APP-010`, and `IAM-010` a common vocabulary to cite instead of each naming technologies independently.

**Update (2026-07-14):** every row below is now backed by an approved ADR (`ADR-040`, `ADR-050`, `ADR-070`, `ADR-090`, `ADR-120`, `ADR-150`, `ADR-160`) and has moved from `Proposed` / `Under Evaluation` to `Approved`. The concrete technologies were confirmed against the current-state inventory (`CS-TEC-010`).

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
| Hosting | DigitalOcean droplet(s) | Approved | Self-managed, no container orchestration | `ADR-040` |
| Reverse proxy / edge | nginx | Approved | Shared edge, sole ingress | `ADR-050` |
| Process management | systemd | Approved | Direct-execution units | `ADR-040` |
| Infrastructure as code | Terraform | Approved | Provisions droplet, DNS, and edge | `ADR-160` |
| CI/CD | GitHub Actions | Approved | Reusable workflow templates | `ADR-150` |
| Application language/framework | Node.js + TypeScript + Express | Approved | Express 5 baseline; `rms` Python worker is a bounded exception | `ADR-070` |
| Primary data store | PostgreSQL (Redis for cache/queue) | Approved | Redis is a supporting store, not a system of record | `ADR-090` |
| Identity provider | Shared OIDC provider (product TBD) | Approved | SSO/OIDC model decided; specific product not yet selected | `ADR-120` |

A row moves to `Approved` only once backed by an ADR recorded in `docs/adr/` (per `DOC-020`) — this table should never assert a technology is `Approved` without a decision record behind it.

## Current-State Gap

Assessed against `CS-TEC-010`, which confirms the hosting, reverse-proxy, and CI choices and records divergent per-application decisions for language, datastore, and identity that this approved stack is the target to converge on.

## Related Documents

- Standards: none directly — this document informs other architecture documents rather than satisfying a standard itself
- ADRs: `ADR-040`, `ADR-050`, `ADR-070`, `ADR-090`, `ADR-120`, `ADR-150`, `ADR-160`, `ADR-180`
- Reference Implementations: `reference/systemd`, `reference/nginx` (both Approved, verified on-host 2026-08-06); `reference/github` (Draft — branch-protection application deliberately deferred, see `docs/development/github-workflow.md`); `reference/terraform` (Approved, real `import` of the production droplet and DNS, 2026-08-07)
- Runbooks: none yet
- Current-State documentation: `CS-TEC-010`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
| 1.0 | 2026-07-13 | Approved | Socx |
| 1.1 | 2026-07-14 | Stack rows moved to Approved; ADR cross-references added | Socx |
| 1.2 | 2026-07-14 | Added current-state cross-reference (CS-TEC-010) | Socx |
| 1.3 | 2026-07-15 | Added ADR-180 cross-reference | Socx |
| 1.4 | 2026-08-06 | reference/systemd moved to Approved (Bootstrap Phase B5 verification) | Socx |
| 1.5 | 2026-08-06 | reference/nginx moved to Approved (on-host deployment: real certificates, full site configs, canary-proven) | Socx |
