---
id: CS-INT-010
title: Current Integration Inventory
category: Integration
status: Approved
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture:
    - INT-010
  standards:
    - ENG-040
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---
# CS-INT-010 — Current Integration Inventory

## Scope

Actual integrations that exist between systems today, and each system's actual API contract discipline. Does not restate the target integration style (see `INT-010`).

## Method

Read from `platform-infra`'s `deployment-architecture.md` (request-flow diagrams) and each application's own API documentation artifacts.

## Inventory

| Fact                                  | Value                                                                                                                                                                                                                                                                                                                     | Evidence                                                                                                                                 |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Request routing today                 | Browser → nginx (TLS-terminated) → matched by`server_name` → proxied to the app's Express instance on a local port (e.g. `127.0.0.1:3030`), path passed through unchanged in the redesign                                                                                                                          | Inferred (redesign target) / Observed (the*previous*, still-presumed-live behaviour strips the `/api/` prefix — see `CS-INF-010`) |
| Cross-system calls                    | **No evidence found of any system calling another system's API.** Each of the four applications' dependency manifests shows only standard web-framework and infrastructure dependencies (Express, Prisma, Redis clients) — no internal HTTP client pointed at another app's domain, no shared internal SDK package | Observed (absence)                                                                                                                       |
| Formal API contracts                  | `rms` has a committed, versioned OpenAPI spec (`infra/rms_openapi_v1.1.yaml`)                                                                                                                                                                                                                                         | Observed                                                                                                                                 |
|                                       | `ams` has Swagger tooling as a dependency (`swagger-jsdoc`, `swagger-ui-express`) but no committed spec file was found                                                                                                                                                                                              | Observed (tooling present, spec absent)                                                                                                  |
|                                       | `ghs` and `socx-org-uk` — no API contract artifact of any kind found                                                                                                                                                                                                                                                 | Observed (absence)                                                                                                                       |
| Known integration defect (historical) | The RMS API prefix-stripping incident (see`CS-INF-010`) was an **nginx-to-Express** integration failure, not a cross-system one — recorded here because it's the only concretely evidenced integration-layer incident found                                                                                      | Inferred                                                                                                                                 |

**Conclusion:** on current evidence, the four applications are integration-independent today — each is a standalone system behind a shared reverse proxy, not yet actually integrating with each other in any direction. This is a simpler reality than `INT-010`'s target, which is written assuming systems already need to call each other.

## Gap vs. Target Architecture

| Aspect                  | Current State                                                                            | Target (`INT-010`)                                               | Difference                                                                                                | Impact                                                                                                                                        |
| ----------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Cross-system calls      | None found                                                                               | Default synchronous HTTPS via the shared edge, versioned contracts | `INT-010` may be solving a problem that doesn't exist yet — no current integration to route or version | Low urgency:`INT-010` remains valid as a plan for *when* integration starts, but nothing today violates it, because nothing today does it |
| API contract discipline | Inconsistent — one of four systems has a real spec, one has tooling only, two have none | `INT-010` implies versioned contracts for any exposed endpoint   | Only`rms` currently meets any contract-discipline bar                                                   | If/when cross-system calls begin,`ghs`, `socx-org-uk`, and `ams` would need contract work first                                         |

## Related Documents

- Architecture: `INT-010`
- Standards: `ENG-040`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
