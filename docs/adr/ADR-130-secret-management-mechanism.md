---
id: ADR-130
title: Platform secret-management mechanism
status: Approved
category: Security & Identity
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - IAM-010
    - INF-010
    - APP-010
  standards:
    - SEC-010
  current_state:
    - CS-IAM-010
    - CS-TEC-010
  reference:
    - reference/security
  runbooks: []
  adrs: []
supersedes: []
superseded_by: null
---

# ADR-130 — Platform secret-management mechanism

## Context

`SEC-010` requires production secrets to be sourced from "a dedicated secret store or the deployment platform's secret mechanism (CI provider secrets, systemd credentials, environment injected at deploy time) — never hardcoded," but it deliberately does not pick one. `APP-010` assumes configuration and secrets are read once at startup from that mechanism. `INF-010` establishes systemd-managed processes behind a shared edge as the target runtime.

The current state, per `CS-IAM-010` and `CS-TEC-010`: applications use a **`.env` / environment-variable pattern** (`ghs` has `.env.example` / `.env.production`), secrets are read from environment variables at runtime, and **no dedicated secret-management service** was found. This satisfies "not committed" only if the `.env` files stay out of git; it does not yet constitute a deliberate platform mechanism.

This ADR chooses the one mechanism the platform standardises on, so `SEC-010`'s list of acceptable options resolves to a single approved default.

## Decision

The platform adopts **systemd credentials** as the primary mechanism for delivering production secrets to services, consistent with the systemd-managed runtime in `INF-010`. Secrets are injected at deploy time and are never present in the repository. This decision is scoped to the current single-droplet systemd hosting model and is revisited if that model changes (see `ADR-040`).

## Alternatives Considered

- **systemd credentials — selected.** Aligns directly with the `INF-010`/`reference/systemd` runtime; keeps secrets off disk in plaintext and out of the process environment where practical; no additional infrastructure to run. Tied to the systemd hosting model.
- **CI-provider (GitHub Actions) secrets injected at deploy** — good for build/deploy-time secrets and already available given `ADR-150`; weaker fit for long-lived runtime secrets, which still need somewhere to live on the host.
- **Dedicated secret store (e.g. HashiCorp Vault, DigitalOcean-managed)** — strongest isolation, rotation, and audit; disproportionate operational overhead for the current single-droplet topology, and adds a new run-time dependency. A candidate to revisit if the platform scales beyond `INF-010`'s current shape.
- **Status-quo `.env` files** — Rejected as the *target*: acceptable only as a local-development convenience, too easy to leak as a production mechanism, and not a deliberate platform choice.

## Consequences

- Naming one mechanism turns `SEC-010`'s open list into a single approved default that `reference/security` can then demonstrate concretely.
- Choosing systemd credentials couples secret management to the systemd runtime decision (`ADR-040`); a future move to containers/orchestration would supersede this ADR.
- Existing apps' `.env`-based production handling becomes a migration target, and `SEC-010.4` (rotation on exposure) gains a concrete place to happen.
- Where auth signing keys and any future identity-provider secrets live (`ADR-120`) is answered by this mechanism.

## Related Documents

- Architecture: `IAM-010`, `INF-010` (systemd runtime), `APP-010` (startup config loading)
- Standards: `SEC-010` (secrets management)
- Current-State documentation: `CS-IAM-010`, `CS-TEC-010`
- Reference Implementations: `reference/security` (**Approved** — verified on-host 2026-08-07: real `set-credential.sh` write, atomic-write and empty-input-refusal paths, `LoadCredential=` consumption confirmed against a real running service)
- Runbooks: none yet — secret rotation is a likely runbook once this is settled
- ADRs: `ADR-040` (hosting & process-runtime model this depends on), `ADR-120` (identity — consumer of this mechanism), `ADR-150` (CI/CD — deploy-time injection)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
