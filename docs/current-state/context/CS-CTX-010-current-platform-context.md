---
id: CS-CTX-010
title: Current Platform Context
category: Context
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture:
    - CTX-010
  standards:
    - OPS-010
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---

# CS-CTX-010 — Current Platform Context

## Scope

Who or what actually interacts with the platform today, and which systems actually sit inside the boundary, as observed. Does not describe intended boundary or actors (see `CTX-010`).

## Method

Derived from `REP-010`'s repository inventory and each application's own README/docs. No access to production traffic logs, analytics, or an actual user register — external actor claims below are Inferred from each application's stated purpose, not confirmed by observing real usage.

## Inventory

**Systems actually inside the boundary today** (per `REP-010` and `platform-infra`'s nginx/systemd naming): `socx-org-uk` (served as `www`), `ghs`, `rms`, `ams` — four applications, not the three named in the project charter. All four are fronted by a single shared edge, per `platform-infra`.

| Actor (inferred) | Interacts with | Basis |
|---|---|---|
| Golf club administrators / players | `ghs` | Repo purpose statement: "golf handicap management system" — Inferred |
| Recipients of reminders/notifications | `rms` | Repo purpose statement: "reminder-centred notification platform" — Inferred |
| Staff managing physical/digital assets | `ams` | Repo purpose statement: "asset management platform"; "asset-ownership access filter" feature seen in commit history — Inferred |
| Visitors to the org's public site | `socx-org-uk` (`www`) | Repo name and nginx `www.socx.org.uk` binding — Inferred |
| Deploy/ops automation (GitHub Actions) | All four, via SSH to the shared droplet | CI workflows present in `ghs` and `rms`; deploy flow described in `platform-infra`'s `deployment-architecture.md` — Observed (workflow files exist), Inferred (that they currently execute against production) |

**Unknown:** actual end-user counts, actual organizations/clubs using `ghs`, whether `rms` and `ams` have any external (non-staff) users at all, and whether any of the four applications currently has authenticated users in production versus being pre-launch. None of this is evidenced in either repository set.

## Gap vs. Target Architecture

| Aspect | Current State | Target (`CTX-010`) | Difference | Impact |
|---|---|---|---|---|
| Systems in boundary | 4 applications (`socx-org-uk`, `ghs`, `rms`, `ams`) | 3 named (`socx-org-uk`, `ghs`, `rms`) | `ams` exists and is deployed but isn't in the target document at all | `CTX-010` and the project charter understate the platform's actual footprint; any capacity, security, or ownership planning based on those documents will miss `ams` entirely |
| External actors | Inferred only, from repo names/purpose statements | Explicitly marked "TBD — confirm" in `CTX-010` | Both current and target are unconfirmed | Low — both sides already agree this is open; no new risk introduced |

## Related Documents

- Architecture: `CTX-010`
- Standards: `OPS-010`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
