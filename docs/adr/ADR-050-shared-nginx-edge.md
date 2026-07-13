---
id: ADR-050
title: Shared nginx edge as sole ingress
status: Approved
category: Infrastructure
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - INF-010
    - INT-010
    - CTX-010
  standards:
    - OPS-010
  current_state:
    - CS-INF-010
  reference:
    - reference/nginx
  runbooks: []
  adrs:
    - ADR-040
    - ADR-100
supersedes: []
superseded_by: null
---

# ADR-050 — Shared nginx edge as sole ingress

## Context

The platform hosts several systems on shared infrastructure, so something must decide how external traffic reaches them. `CS-INF-010` confirms a single droplet's nginx already fronts all applications (`socx.org.uk` plus per-app subdomains), terminates TLS, and proxies to each application's local Express port — matching `INF-010`'s target shape. This ADR settles whether that shared edge is the platform's committed ingress pattern.

## Decision

A **single shared nginx edge is the sole ingress** for the platform. It terminates all external TLS and routes to systems by hostname; no application process is directly internet-facing. Each application is served behind the edge on a private local port. The refinement from one monolithic nginx config to one config file per application — the "one failure domain per app" principle in `platform-infra`'s redesign — is an implementation detail of this decision, realised in `reference/nginx`, not a separate architectural choice.

## Alternatives Considered

- **Each application binds its own public port and TLS** — Rejected: multiplies the externally exposed attack surface and the certificate/renewal burden, and leaves no single place to see or secure ingress.
- **A managed cloud load balancer as the edge** — Rejected at current scale: adds cost and coupling for a single-droplet deployment. Revisit under `ADR-040` if the hosting model changes.
- **Service mesh / per-service ingress** — Rejected: disproportionate for four independent systems that make no cross-system calls today (`CS-INT-010`).

## Consequences

- One place enforces TLS and, in future, edge concerns (rate limiting, security headers).
- The edge is a single point of failure. `CS-INF-010` records the current live risk concretely: one monolithic `apps.conf` (a bad config for one app can break all four) and a past `/api`-prefix-stripping incident. The per-app-config refinement directly mitigates the first.
- Ingress is coupled to the systemd-managed local-port runtime decided in `ADR-040`.

## Related Documents

- Architecture: `INF-010`, `INT-010`, `CTX-010`
- Standards: `OPS-010`
- Current-State documentation: `CS-INF-010`
- Reference Implementations: `reference/nginx`
- Runbooks: none yet
- ADRs: `ADR-040` (the runtime the edge routes to), `ADR-100` (integration routed through this edge)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
