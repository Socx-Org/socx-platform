---
id: CS-IAM-010
title: Current Identity & Access Inventory
category: Identity
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture:
    - IAM-010
  standards:
    - SEC-010
    - SEC-030
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---

# CS-IAM-010 — Current Identity & Access Inventory

## Scope

Actual accounts and the actual trust/auth mechanism in use today. Does not restate the target trust model (see `IAM-010`).

## Method

Read from each application's `package.json` dependencies and `.env.example` files. No access to any live user database, identity provider console, or infrastructure access-control list.

## Inventory

| Fact | Value | Evidence |
|---|---|---|
| End-user authentication | Each of `ghs`, `rms`, and `ams` implements its **own, independent** JWT-based authentication (`jsonwebtoken` present in all three, with per-app `JWT_SECRET`/`JWT_REFRESH_SECRET` in `ghs`'s `.env.example`) | Observed |
| Shared identity provider | **None found.** No SSO library, OAuth/OIDC client, or shared-identity package appears in any of the four applications' dependency lists | Observed (absence) |
| Password storage | Three different hashing libraries across three apps (`bcryptjs` in `ghs`, `bcrypt` in `rms`, `argon2` in `ams`) — see `CS-TEC-010` | Observed |
| Multi-factor authentication | `ams` implements TOTP-based 2FA (`otplib`, `qrcode`); no evidence of MFA in `ghs`, `rms`, or `socx-org-uk` | Observed (`ams`); Observed-absence (others) |
| Service-to-service auth | No evidence of any service-to-service credential exchange — consistent with `CS-INT-010`'s finding that no cross-system calls currently exist | Observed (absence) |
| Infrastructure/repository access control | Unknown — no CODEOWNERS file, access-control list, or team-membership record found in any repository inspected | Unknown |
| Secrets handling | `.env` / `.env.example` / `.env.production` pattern used by `ghs`; secrets read from environment variables at runtime in all apps inspected; no evidence of a dedicated secret-management service | Observed (`ghs`); Inferred (pattern likely shared by the others, not individually confirmed for each) |

**This directly answers `IAM-010`'s open question.** `IAM-010` (architecture) leaves unresolved "whether end users authenticate once against a shared identity provider or separately per system." Current evidence gives a clear answer: **separately, per system, today** — three independent JWT implementations, no shared provider, no SSO. If single sign-on is ever wanted, it is a deliberate future migration across three already-live auth systems, not a green-field choice.

## Gap vs. Target Architecture

| Aspect | Current State | Target (`IAM-010`) | Difference | Impact |
|---|---|---|---|---|
| End-user trust model | Confirmed: independent per-system JWT auth, no SSO | Explicitly left open as a proposal pending an ADR | This inventory resolves the open question as a fact, even though no ADR has been written | `IAM-010` can now be updated from "open item" to a confirmed baseline — recommended as a follow-up, not performed here |
| Password hashing consistency | Three different libraries, none shared | Not explicitly addressed by `IAM-010` (that's more an `APP-010`/`SEC-010` concern) | N/A — flagged here since it surfaced during this inventory | Any future shared-auth work would need to reconcile or migrate all three, not just adopt one |
| MFA | Only one of four apps (`ams`) has it | `SEC-030` doesn't mandate MFA for end users (only for infrastructure/repo access) | No standards gap — `ams` exceeds the baseline, others simply haven't added it | Low — noted for completeness, not a compliance issue |

## Related Documents

- Architecture: `IAM-010`
- Standards: `SEC-010`, `SEC-030`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
