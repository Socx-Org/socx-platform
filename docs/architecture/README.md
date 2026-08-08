# Architecture

Target-state documentation: how the platform is intended to be designed and built.

Content here describes the desired end state — intended service topology, design patterns, integration contracts — regardless of whether the current deployment has caught up yet (see [docs/current-state](../current-state) for that).

Significant changes to the target state should be recorded as an ADR under [docs/adr](../adr).

## Scope

```scheme

        - APP-010 — Application reference architecture
        - APP-020 — Configuration management pattern
```

An architecture document describes the target design and the reasoning behind it. It does not restate:

- **what** every project MUST do (that's an Engineering Standard)
- **why** a specific decision was made, in full (that's an ADR — architecture links to it, doesn't re-argue it)
- **what** a compliant implementation actually looks like (that's a Reference Implementation)
- **how to operate** something right now (that's a Runbook)
- **what** is actually deployed today (that's Current-State documentation)

An architecture document MUST link to the relevant standard, ADR, reference implementation, runbook, or current-state document rather than duplicating its content.

## Architecture Principles

Every architecture document should default toward these unless a specific, recorded reason (an ADR) says otherwise:

- **Simplicity** — the simplest design that satisfies the requirement; complexity has to earn its place.
- **Secure by default** — the default configuration is the secure one; an insecure option requires explicit, documented justification.
- **Infrastructure as code** — target designs assume infrastructure is defined and changed as code, never manually (see `OPS-020`).
- **Externalised configuration** — configuration and secrets are supplied at runtime (see `SEC-010`), never hardcoded into a design.
- **Stateless services where practical** — services hold no local state that would block horizontal scaling or complicate rollback (see `OPS-030`), except where a data-ownership need (`DAT-010`) genuinely requires it.
- **Automation first** — a manual, repeatable operational step is a candidate for automation before it's accepted as a permanent runbook step.

These are design biases, not testable rules. Where a principle and an Engineering Standard overlap, the standard is the enforceable bar — the principle just explains the default every architecture document should design toward.

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

## Architecture Decision Matrix

| Document | Question it answers |
|---|---|
| `CTX-010` | Who or what is outside the platform boundary, and why does the platform exist? |
| `DOM-010` | What systems make up the platform, and how do they relate? |
| `APP-010` | How should any SOCX application be internally structured? |
| `DAT-010` | Who owns which data, how does it flow, and how long is it kept? |
| `INT-010` | How do systems communicate with each other? |
| `TEC-010` | Which technologies are approved, and why? |
| `INF-010` | What does the target hosting/networking shape look like? |
| `IAM-010` | How is trust established between systems and users? |

## Table of Contents

| ID      | Title                                   | Status |
| ------- | --------------------------------------- | ------ |
| CTX-010 | Platform Context                        | Approved  |
| DOM-010 | System Landscape                        | Approved  |
| APP-010 | Application Reference Architecture      | Approved  |
| DAT-010 | Platform Data Architecture              | Approved  |
| INT-010 | Integration Architecture                | Approved  |
| TEC-010 | Approved Technology Stack               | Approved  |
| INF-010 | Target Infrastructure Topology          | Approved  |
| IAM-010 | Identity, Trust & Security Architecture | Approved  |

Status is one of `Planned`, `Draft`, `Approved`, `Deprecated` — the authoritative status for a given document is the `status` field in its own metadata, not this table; this column is kept in sync as a convenience index.

## Diagrams

Diagram source files live in [docs/diagrams](../diagrams), not in a nested `docs/architecture/diagrams/` — diagrams are a cross-cutting asset shared by architecture, runbooks, and ADRs alike. A diagram is ID-prefixed with the document that owns it (e.g. `docs/diagrams/CTX-010-platform-context.drawio`) and is embedded or linked from that document, never copied into it.

## Repository Maturity / Roadmap

| Deliverable | Status |
|---|---|
| 1 — Repository Foundation | Complete |
| 2 — Engineering Standards | Complete — 19 standards Approved |
| 3 — Architecture Documentation | In progress — 8 seed documents Drafted, pending review |
| 4+ — ADRs, Claude Code Integration, Infrastructure Reference Assets, GitHub Standards, Diagram Library, Operational Runbooks, Automation Scripts, Reference Application, Production Readiness Review | Planned |

Full deliverable roadmap and rationale: [docs/project/project-charter.md](../project/project-charter.md).

## Authoring a New Architecture Document

1. Copy [templates/architecture/architecture-doc-template.md](../../templates/architecture/architecture-doc-template.md) into the appropriate category folder under `docs/architecture/`.
2. Name it `<ID>-<slug>.md`.
3. Fill in the metadata block and body.
4. Add a row to the Table of Contents above.
