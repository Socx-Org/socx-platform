---
id: IAM-010
title: Identity, Trust & Security Architecture
category: Identity
status: Draft
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - SEC-010
    - SEC-030
  adrs: []
  reference:
    - reference/security
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# IAM-010 — Identity, Trust & Security Architecture

## Scope

The target trust model between SOCX systems: how they authenticate to each other, where authorization decisions are made, and what crosses a trust boundary. Does not restate the minimum access-control rules every project MUST meet (see `SEC-030`) or concrete secret storage configuration (see `reference/security`) — this document describes the target design; those state the rule and the implementation, respectively.

## Context

As soon as more than one system needs to call another (per `INT-010`), the platform needs an explicit answer to "how does system B know this request from system A is legitimate" — without one, each integration point tends to invent its own trust mechanism.

**Open item:** whether end users authenticate once against a shared identity provider or separately per system is not yet decided. The target below is a proposal, not a confirmed decision — it should be backed by an ADR before this document is Approved.

## Target Design

**Service-to-service trust (proposed):** a system calling another system through the shared edge (`INF-010`) authenticates using a credential scoped to that specific caller-callee pair, sourced per `SEC-010` — never a shared platform-wide credential. This keeps a single compromised credential's blast radius limited to one integration point rather than the whole platform.

**End-user trust (proposed, unconfirmed):** two options are open and neither is yet decided:
- Each system owns and authenticates its own end users independently, or
- A shared identity provider issues a single identity usable across systems (single sign-on).

The choice affects `APP-010`'s interface layer (whether it validates its own credentials or delegates to a shared provider) and should be made deliberately and recorded as an ADR, not defaulted to by whichever system is built first.

**Access control:** who or what may reach a given system or environment follows `SEC-030` (least privilege, MFA, per-person/per-service credentials) — this document doesn't restate those rules, only where the trust boundaries they apply to actually sit.

## Current-State Gap

Not yet assessed.

## Related

- Standard(s) this design satisfies: `SEC-010`, `SEC-030`
- ADR(s) behind this design: none yet — the end-user identity model decision is explicitly outstanding
- Reference implementation(s): `reference/security` (currently empty)
- Runbook(s): none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
