---
id: ADR-180
title: Greenfield platform rebuild on a fresh droplet
status: Approved
category: Infrastructure
version: "1.0"
date: 2026-07-15
deciders: Platform Engineering
related:
  architecture:
    - INF-010
    - TEC-010
  standards:
    - OPS-010
    - OPS-020
    - OPS-060
  current_state:
    - CS-INF-010
    - CS-INF-020
    - CS-DAT-010
    - CS-TEC-010
  reference: []
  runbooks: []
  adrs:
    - ADR-040
    - ADR-140
    - ADR-160
supersedes: []
superseded_by: null
---

# ADR-180 — Greenfield platform rebuild on a fresh droplet

> This ADR ratifies a decision already executed in July 2026: the original droplet has been retired and its replacement provisioned. The record exists so the transition — and the disposition of everything on the old host — is durable and citable, not tribal knowledge.

## Context

The original DigitalOcean droplet's condition was thoroughly documented by the Current-State inventories (all citations are to those point-in-time records, retained as evidence):

- systemd units launched Node through fragile `nvm`/login-shell wrappers; the clean redesign existed only as 0-byte scaffold files (`CS-INF-010`)
- a single monolithic nginx config served all applications — one bad config could take down all four — and had already caused a confirmed incident (the `/api`-prefix stripping failure, `CS-INF-010`)
- no backup mechanism could be confirmed anywhere (`CS-DAT-010`)
- no non-production tier existed, violating `OPS-010.1` (`CS-INF-010`)

Meanwhile, the governing documentation is now complete: 19 standards, 8 architecture documents, 17 approved ADRs, and a reference-implementation library in progress. The platform faced a choice: remediate the old host in place, or rebuild from scratch against the governing documents.

## Decision

The platform is rebuilt **greenfield**:

1. The original droplet is **retired**. No data was migrated, snapshotted, or exported — it held no production data worth keeping (test/development data only).
2. A **fresh Ubuntu 24.04 LTS droplet** is provisioned as the new host, and DNS for `socx.org.uk` and all subdomains is repointed to it (observed: all five hostnames resolve to the new address).
3. The platform is rebuilt on it **strictly from the governing documents** — standards, architecture, ADRs, and the reference implementations in their approved order — via a bootstrap phase followed by the Deliverable 6 build-out. Nothing is carried over from the old host.
4. **Interim posture, explicitly recorded as time-boxed exceptions per `GEN-010.9`:**
   - the new droplet was provisioned by hand — an `OPS-020` exception, closed when `reference/terraform` (ADR-160) imports it into managed state;
   - the single droplet serves as production with no non-production tier — an `OPS-010.1` exception, closed when the second tier is provisioned as code.

## Alternatives Considered

- **Greenfield rebuild — selected.** A clean baseline that satisfies the standards from first boot; none of the documented defects can leak forward; cheap precisely because there was no production data to protect.
- **In-place remediation** — Rejected: every documented defect would have to be unwound on a live host carrying undocumented state; the empty-scaffold redesign already showed this path stalling.
- **Parallel build with gradual cutover** — Rejected: double hosting cost and a long dual-maintenance window bought protection the platform didn't need — with no production data or confirmed production users (`CS-CTX-010`, `CS-DAT-010`), there was nothing requiring a gradual migration.

## Consequences

- The platform has a service gap: nothing is deployed until the rebuild lands. Accepted, given no production data or confirmed users existed.
- `CS-INF-010` is Deprecated (its subject was decommissioned) and superseded by `CS-INF-020`; its findings remain the citable evidence base for ADR-040/050/130 and `reference/systemd`.
- The other Current-State inventories are revised in place — their repo-derived facts survive the transition; only deployment-derived facts changed.
- The fresh droplet becomes the verification host the reference-implementation `verified` gate requires; the Deliverable 6 order becomes the literal rebuild order.
- The bootstrap procedure must be captured as it is executed — it is the seed material for the first operational runbook (Deliverable 7) and automation (Deliverable 8).
- Two `GEN-010.9` exceptions are open and must be visibly tracked until `reference/terraform` closes them.

## Related Documents

- Architecture: `INF-010`, `TEC-010` (targets unchanged — this ADR changes the substrate instance, not the design)
- Standards: `OPS-010`, `OPS-020` (both under recorded exception), `OPS-060`
- Current-State documentation: `CS-INF-010` (evidence, deprecated), `CS-INF-020` (successor baseline), `CS-DAT-010`, `CS-TEC-010`
- Reference Implementations: the library at `reference/` — the rebuild's source material
- Runbooks: none yet — the bootstrap capture seeds Deliverable 7
- ADRs: `ADR-040` (the hosting model this instance implements), `ADR-140` (the tier model the exception is measured against), `ADR-160` (the tooling that closes both exceptions)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-15 | Initial draft | Socx   |
| 1.0     | 2026-07-15 | Approved      | Socx   |
