---
id: ADR-120
title: End-user identity model
status: Approved
category: Security & Identity
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - IAM-010
    - APP-010
    - TEC-010
  standards:
    - SEC-030
    - SEC-010
  current_state:
    - CS-IAM-010
  reference: []
  runbooks: []
  adrs: []
supersedes: []
superseded_by: null
---

# ADR-120 — End-user identity model

## Context

`IAM-010` leaves open "whether end users authenticate once against a shared identity provider or separately per system." `CS-IAM-010` answers what exists **today**, with clarity:

- Each of `ghs`, `rms`, and `ams` implements its **own independent JWT-based authentication** (`jsonwebtoken` in all three, per-app `JWT_SECRET` / `JWT_REFRESH_SECRET`).
- **No shared identity provider, SSO, or OAuth/OIDC client** appears in any application.
- Password storage uses **three different hashing libraries**: `bcryptjs` (`ghs`), `bcrypt` (`rms`), `argon2` (`ams`).
- **MFA exists in only one app**: `ams` (TOTP via `otplib`).

So the current model is *per-system, independent* — not by decision, but by each app arriving there separately. This ADR is where the platform chooses whether to **formalise** that or **converge** on shared identity. Because three live auth systems already exist, shared SSO is now a brownfield migration, not a green-field design.

## Decision

The platform adopts a **shared identity provider (SSO / OIDC)** as the target end-user identity model: all systems delegate end-user authentication to one provider rather than each authenticating independently. The current per-system JWT implementations in `ghs`, `rms`, and `ams` are the migration starting point, not the target.

1. **Trust model** — a single shared identity provider (SSO / OIDC) is the target. Systems validate provider-issued identity rather than minting their own end-user JWTs. This adds an identity-provider row to `TEC-010` and shapes `APP-010`'s interface layer toward delegation.
2. **Password hashing** — where the platform stores passwords, it standardises on **argon2** (already used by `ams`). `ghs` (`bcryptjs`) and `rms` (`bcrypt`) migrate on next successful login. Once the shared provider owns primary authentication, password storage consolidates behind it.
3. **MFA** — MFA is delivered centrally by the shared provider once it lands (generalising `ams`'s TOTP rather than re-implementing per system). Whether MFA is mandatory for all end users is a follow-up policy decision; `SEC-030` mandates MFA for infrastructure/repository access, not yet for end users.

## Alternatives Considered

- **Adopt a shared identity provider (SSO / OIDC) — selected.** A single sign-on identity across systems; better long-term user experience and central control of MFA and revocation. Cost accepted: a migration across three already-live JWT implementations, reshaping `APP-010`'s interface layer (validate-locally → delegate-to-provider) and adding an identity provider to `TEC-010`.
- **Formalise per-system JWT authentication as the target** — Rejected as the target. Lowest cost and matches today's reality, so it is retained as the *starting point* to migrate from — but it accepts permanently separate identities per system and no cross-system SSO, which the platform chose not to settle for.
- **Hybrid — shared provider for new systems, per-system retained for existing** — Rejected: pragmatic, but risks a long-lived split-brain identity estate; the SSO target with a migration path is preferred over an open-ended hybrid.
- **Do nothing / leave open** — Rejected: `IAM-010` explicitly cautions against letting the model be set by default; the divergence (three password libraries) already shows the cost of no decision.

## Consequences

- The platform commits to a migration project: standing up a shared identity provider, adding a `TEC-010` identity-provider row (see `ADR-130` for where its secrets live), and moving `ghs`, `rms`, and `ams` from self-minted JWTs to delegated authentication. This centralises MFA, revocation, and audit.
- `APP-010`'s interface layer moves from validating its own credentials toward delegating to the shared provider; new systems should be built against the provider from the start rather than adding another independent auth implementation to reconcile later.
- Standardising password hashing on `argon2` turns three divergent libraries into one, requiring a rehash-on-next-login migration for `ghs` and `rms`; this storage consolidates behind the shared provider as it takes over primary authentication.
- Until the provider is in place, the per-system JWT implementations remain the operational reality — this ADR sets the target and the direction of travel, and the migration itself is follow-on work (a candidate reference implementation and runbook).

## Related Documents

- Architecture: `IAM-010` (open question this resolves), `APP-010` (interface layer affected), `TEC-010` (identity-provider row)
- Standards: `SEC-030` (access control, MFA), `SEC-010` (secrets — token/signing keys)
- Current-State documentation: `CS-IAM-010`
- Reference Implementations: none yet
- Runbooks: none yet
- ADRs: `ADR-130` (secret-management mechanism — where auth signing keys / provider secrets are stored)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
