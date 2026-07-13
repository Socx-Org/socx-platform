---
id: ADR-110
title: Service-to-service trust
status: Approved
category: Security & Identity
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - IAM-010
    - INT-010
  standards:
    - SEC-010
    - SEC-030
  current_state:
    - CS-IAM-010
    - CS-INT-010
  reference: []
  runbooks: []
  adrs:
    - ADR-120
    - ADR-130
    - ADR-100
supersedes: []
superseded_by: null
---

# ADR-110 — Service-to-service trust

## Context

As soon as one system calls another (`ADR-100` / `INT-010`), the callee needs to know a request from the caller is legitimate — without an explicit answer, each integration point invents its own trust mechanism. `CS-IAM-010` and `CS-INT-010` confirm **no service-to-service calls exist today**, so this is a near-green-field decision to make before integration starts. It interacts directly with `ADR-120`, which introduces a shared SSO / OIDC provider for end users.

## Decision

A system calling another authenticates with a credential **scoped to that specific caller→callee pair** — never a shared platform-wide credential — sourced per `ADR-130` / `SEC-010`. Because `ADR-120` adopts a shared OIDC provider, service-to-service trust is realised through **provider-issued service identities via the OAuth2 client-credentials grant**, so service and end-user trust share one identity system rather than two. Until that provider is in place, **per-pair static secrets are the named interim mechanism**.

## Alternatives Considered

- **Per-pair scoped credentials via the shared OIDC provider (client-credentials) — selected.** Least blast radius, reuses `ADR-120`'s provider, centrally revocable and auditable.
- **Per-pair static secrets / API keys (no provider)** — simpler, but more secrets to rotate and no central revocation. A reasonable interim if the OIDC provider isn't ready when integration begins.
- **Mutual TLS between services** — strong authentication, but certificate lifecycle management is heavy for a single-host deployment; revisit if the topology (`ADR-040`) grows.
- **A shared platform-wide credential** — Rejected: a single leak compromises every integration point at once.

## Consequences

- The blast radius of a compromised credential is limited to one integration point.
- Reusing the OIDC provider couples this decision to `ADR-120`'s rollout; until the provider exists, per-pair static secrets are the interim mechanism.
- Where these credentials live is answered by `ADR-130` (systemd credentials).
- No service-to-service authentication exists to migrate (`CS-IAM-010`), so adopting this cleanly is cheap now.

## Related Documents

- Architecture: `IAM-010`, `INT-010`
- Standards: `SEC-010`, `SEC-030`
- Current-State documentation: `CS-IAM-010`, `CS-INT-010`
- Reference Implementations: none yet
- Runbooks: none yet
- ADRs: `ADR-120` (the shared provider this reuses), `ADR-130` (where credentials are stored), `ADR-100` (the calls this secures)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
