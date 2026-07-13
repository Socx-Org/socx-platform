---
id: IAM-010
title: Identity, Trust & Security Architecture
category: Identity
status: Approved
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - SEC-010
    - SEC-030
  adrs:
    - ADR-110
    - ADR-120
    - ADR-130
  reference:
    - reference/security
  runbooks: []
  current_state:
    - CS-IAM-010
supersedes: []
superseded_by: null
---

# IAM-010 — Identity, Trust & Security Architecture

## Scope

The target trust model between SOCX systems: how they authenticate to each other, where authorization decisions are made, and what crosses a trust boundary. Does not restate the minimum access-control rules every project MUST meet (see `SEC-030`) or concrete secret storage configuration (see `reference/security`) — this document describes the target design; those state the rule and the implementation, respectively.

## Context

As soon as more than one system needs to call another (per `INT-010`), the platform needs an explicit answer to "how does system B know this request from system A is legitimate" — without one, each integration point tends to invent its own trust mechanism.

**Resolved (2026-07-14):** the end-user identity model is decided in `ADR-120` — a shared identity provider (SSO / OIDC). The per-system authentication described below is retained as the current baseline and migration starting point, not the target.

## Target Design

**Service-to-service trust (decided — see `ADR-110`):** a system calling another system through the shared edge (`INF-010`) authenticates using a credential scoped to that specific caller-callee pair, sourced per `SEC-010` and realised via the shared identity provider (`ADR-120`, OAuth2 client-credentials) — never a shared platform-wide credential. This keeps a single compromised credential's blast radius limited to one integration point rather than the whole platform.

**End-user trust (decided — see `ADR-120`):** end users authenticate against a **shared identity provider (SSO / OIDC)**; systems delegate authentication to it rather than each issuing their own end-user credentials. Today's per-system authentication (observed in `CS-IAM-010`) is the migration starting point, not the target. This shapes `APP-010`'s interface layer toward delegation — validating provider-issued identity rather than validating its own credentials.

**Access control:** who or what may reach a given system or environment follows `SEC-030` (least privilege, MFA, per-person/per-service credentials) — this document doesn't restate those rules, only where the trust boundaries they apply to actually sit.

## Current-State Gap

See `CS-IAM-010`: today's model is independent per-system JWT authentication with no shared provider — the migration starting point for the shared SSO/OIDC target above.

## Related Documents

- Standards: `SEC-010`, `SEC-030`
- ADRs: `ADR-110`, `ADR-120`, `ADR-130`
- Reference Implementations: `reference/security` (currently empty)
- Runbooks: none yet
- Current-State documentation: `CS-IAM-010`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
| 1.0 | 2026-07-13 | Approved | Socx |
| 1.1 | 2026-07-14 | End-user identity resolved (ADR-120); ADR cross-references added | Socx |
| 1.2 | 2026-07-14 | Added current-state cross-reference (CS-IAM-010) | Socx |
