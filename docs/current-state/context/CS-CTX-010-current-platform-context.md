---
id: CS-CTX-010
title: Current Platform Context
category: Context
status: Approved
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "2.0"
last_reviewed: 2026-07-15
review_cycle: quarterly
related:
  architecture:
    - CTX-010
  standards:
    - OPS-010
  adrs:
    - ADR-180
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

**Platform transition (2026-07-15, `ADR-180`):** the droplet serving the platform has been decommissioned and **nothing currently serves traffic** — DNS resolves to the new, empty host (`CS-INF-020`), so no actor can presently interact with any SOCX system. The actor table below therefore records the *intended* actors of the repo-defined systems, unchanged by the transition; it becomes live reality again as each system is redeployed.

**Systems inside the boundary** (per `REP-010`): `socx-org-uk` (`www`), `ghs`, `rms`, `ams` — four applications, not the three named in the project charter. None is currently deployed.

| Actor (inferred)                       | Interacts with                          | Basis                                                                                                                                                                                                                  |
| -------------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Golf club administrators / players     | `ghs`                                 | Repo purpose statement: "golf handicap management system" — Inferred                                                                                                                                                  |
| Recipients of reminders/notifications  | `rms`                                 | Repo purpose statement: "reminder-centred notification platform" — Inferred                                                                                                                                           |
| Staff managing physical/digital assets | `ams`                                 | Repo purpose statement: "asset management platform"; "asset-ownership access filter" feature seen in commit history — Inferred                                                                                        |
| Visitors to the org's public site      | `socx-org-uk` (`www`)               | Repo name and nginx`www.socx.org.uk` binding — Inferred                                                                                                                                                             |
| Deploy/ops automation (GitHub Actions) | All four, via SSH to the shared droplet | CI workflows present in`ghs` and `rms` — Observed (workflow files exist). Any deploy steps targeting the retired droplet are now dead until re-pointed at the new host during the rebuild (`ADR-180`) |

**Unknown:** actual end-user counts, actual organizations/clubs using `ghs`, whether `rms` and `ams` have any external (non-staff) users at all, and whether any of the four applications currently has authenticated users in production versus being pre-launch. None of this is evidenced in either repository set.

## Gap vs. Target Architecture

| Aspect              | Current State                                               | Target (`CTX-010`)                             | Difference                                                             | Impact                                                                                                                                                                            |
| ------------------- | ----------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Systems in boundary | 4 applications (`socx-org-uk`, `ghs`, `rms`, `ams`) | 3 named (`socx-org-uk`, `ghs`, `rms`)      | `ams` exists and is deployed but isn't in the target document at all | `CTX-010` and the project charter understate the platform's actual footprint; any capacity, security, or ownership planning based on those documents will miss `ams` entirely |
| External actors     | Inferred only, from repo names/purpose statements           | Explicitly marked "TBD — confirm" in`CTX-010` | Both current and target are unconfirmed                                | Low — both sides already agree this is open; no new risk introduced                                                                                                              |

## Related Documents

- Architecture: `CTX-010`
- Standards: `OPS-010`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
| 2.0     | 2026-07-15 | Platform transition (ADR-180): nothing serving traffic; actor table reframed as intended actors | Socx   |
