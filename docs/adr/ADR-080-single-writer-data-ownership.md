---
id: ADR-080
title: Single-writer data ownership
status: Approved
category: Data
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - DAT-010
    - INT-010
  standards:
    - OPS-060
  current_state:
    - CS-DAT-010
  reference: []
  runbooks: []
  adrs:
    - ADR-090
    - ADR-100
    - ADR-060
supersedes: []
superseded_by: null
---

# ADR-080 — Single-writer data ownership

## Context

With multiple systems, the platform's biggest data risk is not losing data — it is two systems each becoming a source of truth for the same thing (`DAT-010`). `CS-DAT-010` found each system currently owns its own PostgreSQL database, with no evidence of cross-system database access — so the platform is directionally consistent with this rule already, before it is written down. This ADR settles the ownership rule so it stays that way as integration begins.

## Decision

Each data domain has **exactly one owning system**, which is the only system permitted to write it. Other systems that need the data **read it through the integration mechanism** (`ADR-100` / `INT-010`), never by connecting directly to another system's datastore. Supporting stores such as Redis (`ADR-090`) sit outside this rule. Retention and lifecycle for a domain are set by its owning system, per data domain rather than platform-wide (`DAT-010`).

## Alternatives Considered

- **A shared database across systems** — Rejected: creates hidden coupling and multiple writers — the exact failure mode this ADR prevents.
- **Multiple writers with reconciliation** — Rejected: conflict-resolution complexity with no driver at the platform's current scale.
- **No ownership rule (ad hoc access)** — Rejected: lets accidental dual-sources-of-truth emerge silently, which is expensive to unwind later.

## Consequences

- Cross-system data needs are forced through integration (`ADR-100`), keeping coupling explicit and visible.
- The rule is only enforceable if applications keep persistence behind the data-access layer (`ADR-060`).
- `DAT-010`'s per-domain ownership table is still TBD; this ADR sets the rule, and the concrete domain-to-owner assignments follow as `DOM-010`'s system responsibilities are confirmed.
- Because no cross-system database access exists today (`CS-DAT-010`), adopting this is cheap now and would be expensive to retrofit later.

## Related Documents

- Architecture: `DAT-010`, `INT-010`
- Standards: `OPS-060`
- Current-State documentation: `CS-DAT-010`
- Reference Implementations: none
- Runbooks: none
- ADRs: `ADR-090` (the datastore this governs), `ADR-100` (how non-owners read the data), `ADR-060` (the data-access layer that enforces it)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
