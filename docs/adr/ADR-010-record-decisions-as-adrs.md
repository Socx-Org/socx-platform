---
id: ADR-010
title: Record decisions as ADRs
status: Approved
category: Platform & Governance
version: "1.0"
date: 2026-07-13
deciders: Platform Engineering
related:
  architecture: []
  standards:
    - DOC-020
    - GEN-010
  current_state: []
  reference: []
  runbooks: []
  adrs: []
supersedes: []
superseded_by: null
---

# ADR-010 — Record decisions as ADRs

## Context

The architecture documents and standards in this repository repeatedly defer their rationale to "an ADR" — `TEC-010` carries an empty per-row `ADR` column, and every `related.adrs:` array across the handbook is currently empty. `DOC-020` already defines *when* a decision warrants an ADR, but nothing yet defines *how* an ADR is written, numbered, versioned, and cross-referenced. Without that, each decision record would invent its own shape, and the "why" behind the platform's design would stay scattered across commit messages, pull-request threads, and prose inside documents that are meant to describe *what*, not *why*.

This ADR closes that gap. It is deliberately the first ADR in the log — the record that establishes the practice the rest of the catalogue depends on.

## Decision

The platform records significant architectural and engineering decisions as Architecture Decision Records under `docs/adr/`, governed as follows:

- **Numbering** — `ADR-<NUMBER>`, starting at `010` and incrementing by `10`, consistent with the Standards, Architecture, and Current-State schemes. IDs are permanent once Approved.
- **Category as metadata** — each ADR carries a `category`, used only for indexing; it is not part of the ID, because decisions are frequently cross-cutting.
- **Flat directory** — ADRs live directly in `docs/adr/`; categorisation lives in `docs/adr/README.md`, not in subfolders.
- **Six-section body** — Context, Decision, Alternatives Considered, Consequences, Related Documents, Revision History (see `templates/adr/adr-template.md`).
- **Lifecycle** — `Draft → Approved → Superseded | Deprecated`, plus `Rejected` for a decision intentionally not adopted. An ADR is a point-in-time record and carries no `review_cycle` or `last_reviewed`.
- **Immutability** — per `DOC-020.5`, an Approved ADR is never edited to reverse its decision; a reversal is a new superseding ADR. `version` tracks editorial revisions only.
- **Bidirectional cross-referencing** — on Approval, the `related.adrs:` arrays of the Architecture documents and Standards an ADR names are populated to point back at it.

## Alternatives Considered

- **No formal decision log** — leave rationale in commit messages and pull-request discussion. Rejected: that history is hard to discover, easily lost, and cannot be cited by ID from an architecture document or standard.
- **Rationale embedded in the architecture documents themselves** — Rejected: it conflates *what the design is* with *why it was chosen over alternatives*, and the architecture READMEs already delegate "why" to ADRs explicitly.
- **Flat sequential numbering (`ADR-0001`, MADR default)** — Rejected in favour of the `ADR-010` increment-by-10 scheme, for consistency with every other numbered document type in this repository. The chronological-order signal of dense numbering was judged less valuable than repository-wide uniformity.
- **Category-prefixed IDs (`INF-010`-style, matching Architecture)** — Rejected: many decisions belong to more than one category, and a category-prefixed ID would force a false single home. Category is captured as metadata instead.

## Consequences

- The empty `related.adrs:` arrays and `TEC-010`'s ADR column now have a defined thing to point at, giving every design and standard a traceable rationale.
- New decisions carry an authoring cost (weighing and writing up alternatives) — intentionally, as the bar in `DOC-020` keeps that cost proportionate to the decision's significance.
- Numbering in increments of 10 inside an append-only log leaves visible gaps; this is accepted as the price of repository-wide consistency.
- This ADR is self-applying: it is itself the first record written under the practice it defines.

## Related Documents

- Architecture: none directly — this ADR is the link *target* for the architecture catalogue
- Standards: `DOC-020` (when an ADR is required), `GEN-010` (handbook governance)
- Current-State documentation: none
- Reference Implementations: `templates/adr/adr-template.md` (the authoring scaffold)
- Runbooks: none
- ADRs: none — this is the foundational ADR

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
