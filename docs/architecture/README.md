# Architecture

Target-state documentation: how the platform is intended to be designed and built.

Content here describes the desired end state — intended service topology, design patterns, integration contracts — regardless of whether the current deployment has caught up yet (see [docs/current-state](../current-state) for that).

Significant changes to the target state should be recorded as an ADR under [docs/adr](../adr).

## Scope

An architecture document describes the target design and the reasoning behind it. It does not restate:

- **what** every project MUST do (that's an Engineering Standard)
- **why** a specific decision was made, in full (that's an ADR — architecture links to it, doesn't re-argue it)
- **what** a compliant implementation actually looks like (that's a Reference Implementation)
- **how to operate** something right now (that's a Runbook)
- **what** is actually deployed today (that's Current-State documentation)

An architecture document MUST link to the relevant standard, ADR, reference implementation, or runbook rather than duplicating its content.

## Separation of Concerns

| Concern                   | Lives in                | Answers                                    |
| ------------------------- | ----------------------- | ------------------------------------------ |
| Architecture              | `docs/architecture/`  | What the target design is, and why         |
| Current State             | `docs/current-state/` | What is actually deployed today            |
| Engineering Standards     | `docs/standards/`     | What every project MUST do                 |
| ADRs                      | `docs/adr/`           | Why a specific decision was made           |
| Reference Implementations | `reference/`          | What a compliant implementation looks like |
| Runbooks                  | `docs/runbooks/`      | How to operate / respond right now         |

## Document Lifecycle

Architecture documents follow their own lifecycle, independent of the Engineering Standards Handbook's `GEN-010` (which governs standards, not architecture — conflating the two would blur "rules SOCX projects must follow" with "how this repository manages its own documentation").

- A new document starts `status: Draft`, `version: "0.1"`.
- It moves to `status: Approved`, `version: "1.0"` only after explicit review.
- Once Approved, its `id` is permanent — never reused or renumbered.
- A revision increments `version` (minor for a clarifying edit, major for a change to the target design itself) and adds a row to the Revision History table.
- A superseded document is marked `status: Deprecated`, sets `superseded_by`, and is retained rather than deleted — other documents may already cite its ID.
- Every document is reviewed at least once per its stated `review_cycle`, even with no changes, updating `last_reviewed`.

There is no `Exceptions` mechanism for architecture documents (unlike standards) — they describe a target design, not a rule a project can be granted an exception from.

## Numbering Scheme

Each document has a permanent ID: `<CATEGORY>-<NUMBER>`, e.g. `CTX-010`.

- Numbers start at `010` and increment by `10` within each category, leaving room to insert a document later without renumbering anything already Approved and referenced elsewhere.
- Filenames are ID-prefixed (`CTX-010-platform-context.md`) so a directory listing is self-ordering and self-documenting.
- Unlike standards, architecture documents are descriptive rather than normative, so there is no requirement-level sub-numbering (no `CTX-010.1`). What is cited precisely, by ID, is which ADRs justify a design and which standards it satisfies.

## Categories

| Code | Category       | Scope                                                                                                                                                                              |
| ---- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CTX  | Context        | The platform and its external actors — why it exists, who uses it                                                                                                                 |
| DOM  | Domain         | System/bounded-context decomposition and how systems relate                                                                                                                        |
| APP  | Application    | The common internal architecture pattern shared by SOCX applications — not any single application's actual internals, which stay in that application's own repository             |
| DAT  | Data           | Ownership, flow, persistence strategy, lifecycle, retention, and backup strategy for data across systems                                                                           |
| INT  | Integration    | How systems communicate: style and contract conventions                                                                                                                            |
| TEC  | Technology     | The approved platform technology stack and the architectural rationale for each choice                                                                                             |
| INF  | Infrastructure | Target hosting/networking topology — conceptual only; MUST NOT contain deployment configuration, connection strings, ports, or other implementation detail (that's`reference/`) |
| IAM  | Identity       | Target trust, authentication, and authorization model                                                                                                                              |

## Table of Contents

| ID      | Title                                   | Status  |
| ------- | --------------------------------------- | ------- |
| CTX-010 | Platform Context                        | Planned |
| DOM-010 | System Landscape                        | Planned |
| APP-010 | Application Reference Architecture      | Planned |
| DAT-010 | Platform Data Architecture              | Planned |
| INT-010 | Integration Architecture                | Planned |
| TEC-010 | Approved Technology Stack               | Planned |
| INF-010 | Target Infrastructure Topology          | Planned |
| IAM-010 | Identity, Trust & Security Architecture | Planned |

Status is one of `Planned`, `Draft`, `Approved`, `Deprecated` — the authoritative status for a given document is the `status` field in its own metadata, not this table; this column is kept in sync as a convenience index.

## Diagrams

Diagram source files live in [docs/diagrams](../diagrams), not in a nested `docs/architecture/diagrams/` — diagrams are a cross-cutting asset shared by architecture, runbooks, and ADRs alike. A diagram is ID-prefixed with the document that owns it (e.g. `docs/diagrams/CTX-010-platform-context.drawio`) and is embedded or linked from that document, never copied into it.

## Authoring a New Architecture Document

1. Copy [templates/architecture/architecture-doc-template.md](../../templates/architecture/architecture-doc-template.md) into the appropriate category folder under `docs/architecture/`.
2. Name it `<ID>-<slug>.md`.
3. Fill in the metadata block and body.
4. Add a row to the Table of Contents above.
