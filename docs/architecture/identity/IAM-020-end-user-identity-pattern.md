---
id: IAM-020
title: End-user identity implementation pattern
category: Identity
status: Proposed
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-08-10
review_cycle: annual
related:
  standards:
    - SEC-010
    - SEC-030
  adrs:
    - ADR-120
    - ADR-130
    - ADR-210
  reference: []
  runbooks: []
  current_state:
    - CS-IAM-010
supersedes: []
superseded_by: null
---

# IAM-020 — End-user identity implementation pattern

**Status: Proposed.** Not yet validated by a real implementation — `IAM-010`/`ADR-120` set the *target* (shared SSO/OIDC identity provider) and named a concrete design as necessary follow-on work; this document is that design, informing GHS's Phase 1 identity work as its first real, candidate implementation. Moves toward Approved once GHS builds and validates it, the same graduation path `APP-020` describes for Configuration Management.

## Scope

The concrete shape a SOCX application's own end-user identity module takes **today**, while `ADR-120`'s shared identity provider doesn't exist yet — designed so that when it does, adopting it is a boundary swap behind an existing abstraction, not a rewrite. Does not restate `IAM-010`'s trust-model decision or `ADR-120`'s SSO target; this is the concrete pattern underneath both.

## Context

`ADR-120` decided the target (shared SSO/OIDC) but explicitly left the concrete design as separate follow-on work: *"a candidate reference implementation."* No SOCX application has built one yet. GHS's Phase 1 (Domain Data Model) is the first opportunity to build fresh, rather than retrofit — RMS and legacy GHS both show real, working but divergent per-system identity implementations (three password-hashing libraries between them and `ams`, per `CS-IAM-010`), which is exactly the divergence `ADR-120` exists to eventually resolve. Building GHS's identity module as a deliberate candidate for this pattern, rather than a fourth independent implementation, is the point of tracking this separately from GHS's own backlog.

**Evidence honestly scoped:** this design is informed by legacy GHS's real token-table pattern (sound, standard, kept) and RMS's real `user_status` enum shape (richer than GHS's boolean, kept). `ams`'s real MFA implementation (`ADR-120` cites TOTP via `otplib`) was **not** available to inspect directly — its local checkout is an empty placeholder — so the MFA design below is built from standard TOTP practice (RFC 6238), not from `ams`'s actual code. Reconcile against `ams`'s real implementation if/when it becomes available, the same way this pattern should eventually reconcile against whatever real shared IdP `ADR-120`'s migration produces.

## Target Design

### Separation of concerns

Three distinct concerns, three distinct places, kept separate specifically because collapsing them is what makes a later SSO migration expensive:

- **Identity** (`users`) — who can authenticate, and their credential/verification state. Platform-generic; nothing application-specific belongs here.
- **Profile** (e.g. GHS's `players`) — who they are in the consuming application's own domain. Linked by `user_id`, never merged with identity.
- **Authorization** (`role`) — what they can do in the consuming application. A single field for now (no evidence any consuming application needs multi-role-per-user), accessed only through an abstraction, never scattered equality checks through the codebase.

### `AuthProvider` abstraction

The interface layer (`ADR-060`) depends on an interface, not a concrete implementation:

```
interface AuthProvider {
  authenticate(credentials): Promise<Identity>
  verifyToken(token: string): Promise<Identity>
}

interface Identity {
  sub: string;            // stable subject id -- users.id today, the shared provider's subject claim once ADR-120's migration lands
  email: string;
  emailVerified: boolean;
  amr: string[];          // OIDC "authentication methods references" -- e.g. ["pwd"], ["pwd","otp"]
}
```

Today: one implementation (`LocalAuthProvider` — password + argon2 + JWT). Once `ADR-120`'s shared provider exists: a second implementation (`OidcAuthProvider`) drops in behind the same interface — nothing above this layer changes. JWT claims are shaped like OIDC ID-token claims now (`sub`, `email`, `email_verified`, `amr`, application-specific claims namespaced e.g. `ghs_role`) specifically so a later swap to real OIDC tokens is a smaller remap, not a redesign.

### Data model

```
users
  id                 UUID PK
  email              CITEXT UNIQUE NOT NULL
  password_hash      TEXT NOT NULL              -- argon2 (ADR-120's platform standard), zero migration cost for a new build
  status             TEXT NOT NULL DEFAULT 'pending_verification'
                        CHECK (status IN ('pending_verification','active','disabled','deleted'))
  role               TEXT NOT NULL DEFAULT 'player'   -- application-specific values; the column's existence is the pattern, not its values
  email_verified_at  TIMESTAMPTZ NULL
  created_at, updated_at

account_activation_tokens     -- adopted from legacy GHS's real, sound pattern: hashed token, expiry, single-use (used_at)
password_reset_tokens         -- same pattern, + one improvement: invalidate every other outstanding token for a user on successful reset (legacy GHS did not do this)

user_mfa_methods
  id          UUID PK
  user_id     UUID NOT NULL REFERENCES users(id)
  method      TEXT NOT NULL CHECK (method IN ('totp'))   -- only TOTP built now; shape allows webauthn/passkeys later without a schema rewrite
  secret      TEXT NOT NULL       -- encrypted, not hashed -- see Design Decisions
  enabled_at  TIMESTAMPTZ NULL    -- NULL until confirmed with a real code during enrollment
  created_at
  UNIQUE (user_id, method)

user_mfa_backup_codes
  id          UUID PK
  user_id     UUID NOT NULL REFERENCES users(id)
  code_hash   TEXT NOT NULL       -- hashed like a password, single-use
  used_at     TIMESTAMPTZ NULL
  created_at
```

`status`'s four-state shape replaces a bare boolean (legacy GHS) with something closer to RMS's `user_status` enum, extended with `pending_verification` as its own state where RMS's doesn't need one (RMS's email verification is non-blocking; this pattern's is not, matching the product requirement that drove it).

### Registration and activation

- `self_registration_enabled` lives in `system_settings` (`APP-020`), not an environment variable — closes the exact inconsistency legacy GHS had.
- Self-registration always creates `status = 'pending_verification'` plus an activation token; the account cannot authenticate until activated.
- Admin-created accounts take an explicit `autoActivate: boolean` — `true` skips the token and sets `status = 'active'` immediately; `false` follows the same token path as self-registration, so the invited user activates it themselves.
- Resend-activation issues a fresh token and responds identically whether or not the email exists, to avoid leaking which emails are registered — a real improvement over legacy GHS's `409 email_already_exists`, at no extra cost.

### MFA (TOTP, optional)

- Enrollment happens post-authentication, opt-in, never blocking initial account activation: generate a secret → user confirms with a real code → `enabled_at` set and backup codes generated once, shown once.
- Login becomes two-step once MFA is enrolled: password verified → if MFA enabled, issue a narrowly-scoped MFA-pending token (not a session) → verify TOTP or a backup code → issue the real session, with `amr = ["pwd","otp"]`.
- Recovery: backup codes for "lost my device"; admin can clear a user's MFA enrollment for "lost everything," same authority tier as account enable/disable, audited the same way.
- **Optional for all roles** — a deliberate platform-owner decision (2026-08-10), not evidence-derived; `ADR-120` explicitly left mandatory-MFA-for-end-users as a future policy question, unresolved by this document.

## Design Decisions

- **TOTP secrets are encrypted, not hashed.** Every other credential this platform stores (passwords, activation/reset tokens) is hashed — one-way, never read back. Verifying a TOTP code requires the raw secret, so it must be reversible: encrypted at rest, decryption key held via `reference/security`'s `LoadCredential=` mechanism, not a new secret-handling path invented for this. This is the platform's first real case of "encrypted, not hashed" credential storage — worth flagging precisely because getting it backwards (hashing instead of encrypting) would silently and permanently break MFA for every enrolled user.
- **`users`/profile split is non-negotiable, not a style preference.** It's the specific thing that makes `ADR-120`'s eventual migration a boundary swap instead of a rewrite — collapsing identity and domain-profile fields into one table is the single change most likely to make a future SSO migration expensive.
- **Claims shaped like OIDC now, before a real OIDC provider exists.** Free alignment: `sub`/`email`/`email_verified`/`amr` cost nothing to name correctly today and reduce the remap surface later.

## Current-State Gap

Not yet implemented anywhere. GHS's Phase 1 (Domain Data Model) is the first real candidate build. RMS and legacy GHS both have real, working, but divergent identity implementations (`CS-IAM-010`) that this pattern does not require either to migrate to — same posture `ADR-200` took with RMS's Prisma usage: a named default for new work, not a forced migration.

## Related Documents

- Architecture: `IAM-010` (target trust model this pattern implements toward), `APP-020` (Configuration Management — `system_settings` for `self_registration_enabled`)
- Standards: `SEC-010` (secret storage — TOTP encryption key), `SEC-030` (access control, MFA)
- ADRs: `ADR-120` (shared identity provider target, argon2 standard, this document's own reason to exist), `ADR-130` (secret-management mechanism), `ADR-210` (async notification — activation/reset/MFA-enrollment emails route through the outbox, not a direct send)
- Current-State: `CS-IAM-010`
- Reference Implementations: none yet — GHS's Phase 1 implementation is the candidate

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-08-10 | Initial draft, Proposed — informed by GHS Phase 1 identity design discussion | Socx   |
