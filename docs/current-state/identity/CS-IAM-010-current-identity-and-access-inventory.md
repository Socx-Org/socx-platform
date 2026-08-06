---
id: CS-IAM-010
title: Current Identity & Access Inventory
category: Identity
status: Approved
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "2.3"
last_reviewed: 2026-08-06
review_cycle: quarterly
related:
  architecture:
    - IAM-010
  standards:
    - SEC-010
    - SEC-030
  adrs:
    - ADR-180
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

**Platform transition (2026-07-15, `ADR-180`):** application-level identity facts below are repo-derived and unchanged — the code still implements what it implemented. What changed is infrastructure access: the old droplet's accounts went with it, and no application authentication is currently *live* anywhere (nothing is deployed, `CS-INF-020`).

| Fact                                     | Value                                                                                                                                                                                                                             | Evidence                                                                                                |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| End-user authentication                  | Each of`ghs`, `rms`, and `ams` implements its **own, independent** JWT-based authentication (`jsonwebtoken` present in all three, with per-app `JWT_SECRET`/`JWT_REFRESH_SECRET` in `ghs`'s `.env.example`) | Observed                                                                                                |
| Shared identity provider                 | **None found.** No SSO library, OAuth/OIDC client, or shared-identity package appears in any of the four applications' dependency lists                                                                                     | Observed (absence)                                                                                      |
| Password storage                         | Three different hashing libraries across three apps (`bcryptjs` in `ghs`, `bcrypt` in `rms`, `argon2` in `ams`) — see `CS-TEC-010`                                                                                 | Observed                                                                                                |
| Multi-factor authentication              | `ams` implements TOTP-based 2FA (`otplib`, `qrcode`); no evidence of MFA in `ghs`, `rms`, or `socx-org-uk`                                                                                                            | Observed (`ams`); Observed-absence (others)                                                           |
| Service-to-service auth                  | No evidence of any service-to-service credential exchange — consistent with`CS-INT-010`'s finding that no cross-system calls currently exist                                                                                   | Observed (absence)                                                                                      |
| Infrastructure/repository access control | New droplet, per Bootstrap Phases B0–B4 (`CS-INF-020` v0.9): `ubuntu` (unused DigitalOcean default) is **locked out** (password locked, nologin shell); `deploy` has verified, working passwordless sudo independent of root. Firewall is **active** (22/80/443 only). **Root SSH login by key remains permitted** — a standing exception at the platform owner's explicit, reiterated direction, not an oversight. **Four new non-interactive service accounts** (one per application: `socx-org-uk`, `ghs`, `rms`, `ams`) were created in B4 — each locked, no usable password, `nologin` shell; not usable for interactive access, scoped only to their own `/opt/<app>` tree and matching `/etc/credentials/<app>/` directory (least privilege, `SEC-030.1`). Repository side unchanged: no CODEOWNERS file, access-control list, or team-membership record found | Observed (droplet, B0–B4); Unknown (repositories) |
| Secrets handling                         | `.env` / `.env.example` / `.env.production` pattern used by `ghs`; secrets read from environment variables at runtime in all apps inspected; no evidence of a dedicated secret-management service                         | Observed (`ghs`); Inferred (pattern likely shared by the others, not individually confirmed for each) |

**This directly answers `IAM-010`'s open question.** `IAM-010` (architecture) leaves unresolved "whether end users authenticate once against a shared identity provider or separately per system." Current evidence gives a clear answer: **separately, per system, today** — three independent JWT implementations, no shared provider, no SSO. If single sign-on is ever wanted, it is a deliberate future migration across three already-live auth systems, not a green-field choice.

## Gap vs. Target Architecture

| Aspect                       | Current State                                      | Target (`IAM-010`)                                                                    | Difference                                                                               | Impact                                                                                                                    |
| ---------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| End-user trust model         | Confirmed: independent per-system JWT auth, no SSO | Explicitly left open as a proposal pending an ADR                                       | This inventory resolves the open question as a fact, even though no ADR has been written | `IAM-010` can now be updated from "open item" to a confirmed baseline — recommended as a follow-up, not performed here |
| Password hashing consistency | Three different libraries, none shared             | Not explicitly addressed by`IAM-010` (that's more an `APP-010`/`SEC-010` concern) | N/A — flagged here since it surfaced during this inventory                              | Any future shared-auth work would need to reconcile or migrate all three, not just adopt one                              |
| MFA                          | Only one of four apps (`ams`) has it             | `SEC-030` doesn't mandate MFA for end users (only for infrastructure/repo access)     | No standards gap —`ams` exceeds the baseline, others simply haven't added it          | Low — noted for completeness, not a compliance issue                                                                     |

## Related Documents

- Architecture: `IAM-010`
- Standards: `SEC-010`, `SEC-030`
- ADRs: `ADR-180`
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
| 2.0     | 2026-07-15 | Platform transition (ADR-180): infrastructure-access rows updated for the new host; app-level facts unchanged | Socx   |
| 2.1     | 2026-08-06 | Bootstrap Phase B0: corrected account count (two, not one) and recorded root-SSH-permitted finding, per CS-INF-020 v0.3 | Socx   |
| 2.2     | 2026-08-06 | Bootstrap Phase B1: ubuntu locked out, firewall active, deploy sudo verified; root-login reframed as a standing owner-directed exception; fixed stale "ADRs: none yet" (ADR-180 already in frontmatter) | Socx   |
| 2.3     | 2026-08-06 | Bootstrap Phase B4: recorded four new non-interactive per-app service accounts (socx-org-uk, ghs, rms, ams), locked and scoped to their own directory trees | Socx   |
