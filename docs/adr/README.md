# Architecture Decision Records

An ADR records **why** a significant architectural or engineering decision was made — the forces behind it, the alternatives weighed, and the consequences accepted. It is the durable, immutable counterpart to the living documents elsewhere in this repository.

## Scope

An ADR records the reasoning behind one decision. It does not restate:

- **what** the target design is (that's Architecture — it links to the ADR, it doesn't re-argue it)
- **what** every project MUST do (that's an Engineering Standard)
- **what** a compliant implementation looks like (that's a Reference Implementation)
- **how to operate** something right now (that's a Runbook)
- **what** is actually deployed today (that's Current-State documentation)

When an ADR is required versus optional is governed by `DOC-020` (ADR Usage Criteria), not by this README. This README governs how an ADR is written, numbered, and cross-referenced.

## Separation of Concerns

| Concern                       | Lives in               | Answers                                    |
| ----------------------------- | ---------------------- | ------------------------------------------ |
| Architecture Decision Records | `docs/adr/`          | Why a specific decision was made           |
| Architecture                  | `docs/architecture/` | What the target design is                  |
| Current State                 | `docs/current-state/`| What is actually deployed today            |
| Engineering Standards         | `docs/standards/`    | What every project MUST do                 |
| Reference Implementations     | `reference/`         | What a compliant implementation looks like |
| Runbooks                      | `docs/runbooks/`     | How to operate / respond right now         |

## Numbering Scheme

Each ADR has a permanent ID: `ADR-<NUMBER>`, e.g. `ADR-010`.

- Numbers start at `010` and increment by `10`, consistent with the Standards, Architecture, and Current-State schemes — the gaps leave room to file a closely related ADR adjacent to an existing one without renumbering.
- IDs are permanent once Approved. A superseded ADR keeps its ID and points to its successor via `superseded_by` — it is never renumbered or deleted, since other documents may already cite it.
- The **category** (see below) is metadata and an index grouping only — it is deliberately **not** part of the ID, because a single decision is often cross-cutting (e.g. process management is both Infrastructure and Operations), and forcing a category prefix would assign it a false single home.
- Filenames are ID-prefixed (`ADR-050-shared-nginx-edge.md`) so a directory listing is self-ordering and self-documenting.
- ADRs live flat in `docs/adr/`, not in per-category subfolders — the categorisation lives in the index below.

## Lifecycle & Status

An ADR is a point-in-time record, not a periodically re-reviewed living document — so, unlike Standards and Architecture, it carries **no** `review_cycle` or `last_reviewed`.

```
Draft  →  Approved  →  Superseded   (by a later ADR)
                    ↘  Deprecated   (decision no longer relevant, no successor)
       →  Rejected   (records a decision intentionally NOT adopted)
```

- A new ADR starts `status: Draft`, `version: "0.1"`.
- It moves to `status: Approved`, `version: "1.0"` only after explicit review.
- Once Approved, an ADR MUST NOT be edited to reflect a later reversal (per `DOC-020.5`). A reversal is recorded as a **new** ADR that supersedes the old one; the original is retained with `status: Superseded` and `superseded_by` set.
- `version` therefore tracks **editorial** revisions only — a clarifying edit or a filled-in cross-reference — never a change to the decision itself. Each bump adds a Revision History row.
- `Rejected` is used for an ADR that deliberately records an option the platform chose *not* to adopt, so the reasoning is preserved rather than relitigated later.

## Metadata

Every ADR carries the frontmatter defined in [templates/adr/adr-template.md](../../templates/adr/adr-template.md): `id`, `title`, `status`, `category`, `version`, `date`, `deciders`, a `related` block (architecture, standards, current_state, reference, runbooks, adrs), `supersedes`, and `superseded_by`.

## Body Structure

Every ADR uses the same six sections, in order:

| Section | Purpose |
| ------- | ------- |
| **Context** | The forces and problem that make a decision necessary |
| **Decision** | The choice made, stated plainly |
| **Alternatives Considered** | Options weighed and why they were or weren't chosen |
| **Consequences** | What becomes easier, harder, or constrained as a result |
| **Related Documents** | Architecture, Standards, Current-State, Reference, Runbooks, and related/superseding ADRs |
| **Revision History** | Version table, mirroring every other document type |

## Cross-Referencing Conventions

- **Bidirectional, enforced at Approval.** When an ADR is Approved, the (currently empty) `related.adrs:` array in every Architecture document and Standard it names is populated to point back, and the matching `TEC-010` per-row `ADR` cell is filled. The link is never one-way.
- **Single home for the "why."** The ADR is the only place the alternatives-and-consequences argument lives. Other documents cite it by ID and never duplicate its content.
- **Supersession chain** via `supersedes` / `superseded_by`, never in-place edits.
- **Intentional divergence** between Current-State and Architecture is justified by referencing the ADR that sanctioned it.

## Categories

| Category | Scope |
| -------- | ----- |
| Platform & Governance | How the platform governs itself: repository topology, documentation model, engineering philosophy, the ADR practice itself |
| Infrastructure | Hosting substrate, process runtime, edge/ingress |
| Application | Shared application architecture, language, and framework |
| Data | Data ownership model and datastore technology |
| Integration | How systems communicate |
| Security & Identity | Trust model, end-user identity, secret management |
| Operations | Environments, CI/CD, infrastructure-as-code tooling |
| Engineering Process | Version control and engineering workflow |

## Catalogue

The approved ADR catalogue (Deliverable 5). `Status` reflects each ADR document's own lifecycle state; `Decision` records whether the underlying decision is already made (backfill) or still open (requires a formal decision). The authoritative status for a given ADR is the `status` field in its own metadata — this table is kept in sync as a convenience index.

### Platform & Governance

| ID      | Title                                                    | Status   | Decision |
| ------- | -------------------------------------------------------- | -------- | -------- |
| ADR-010 | Record decisions as ADRs                                 | Approved | Made     |
| ADR-020 | Platform governance: multi-repo topology & documentation model | Approved | Made     |
| ADR-030 | Documentation-first engineering philosophy               | Approved | Made     |

### Infrastructure

| ID      | Title                                                    | Status   | Decision |
| ------- | -------------------------------------------------------- | -------- | -------- |
| ADR-040 | Hosting & process-runtime model (droplets, systemd, no orchestration) | Approved | Open     |
| ADR-050 | Shared nginx edge as sole ingress                        | Approved | Made     |

### Application

| ID      | Title                                    | Status   | Decision |
| ------- | ---------------------------------------- | -------- | -------- |
| ADR-060 | Three-layer application reference architecture | Approved | Made     |
| ADR-070 | Application language & framework          | Approved | Open     |

### Data

| ID      | Title                          | Status   | Decision |
| ------- | ------------------------------ | -------- | -------- |
| ADR-080 | Single-writer data ownership   | Approved | Made     |
| ADR-090 | Primary datastore technology   | Approved | Open     |

### Integration

| ID      | Title                                        | Status   | Decision |
| ------- | -------------------------------------------- | -------- | -------- |
| ADR-100 | Default integration style (sync HTTPS via edge) | Approved | Made     |

### Security & Identity

| ID      | Title                                          | Status   | Decision |
| ------- | ---------------------------------------------- | -------- | -------- |
| ADR-110 | Service-to-service trust via scoped credentials | Approved | Open     |
| ADR-120 | End-user identity model (SSO vs per-system)     | Approved | Open     |
| ADR-130 | Platform secret-management mechanism            | Approved | Open     |

### Operations

| ID      | Title                          | Status   | Decision |
| ------- | ------------------------------ | -------- | -------- |
| ADR-140 | Environment model              | Approved | Made     |
| ADR-150 | CI/CD platform (GitHub Actions) | Approved | Open     |
| ADR-160 | Infrastructure-as-code tooling  | Approved | Open     |

### Engineering Process

| ID      | Title                                      | Status   | Decision |
| ------- | ------------------------------------------ | -------- | -------- |
| ADR-170 | Trunk-based development & commit conventions | Approved | Made     |

## Authoring a New ADR

1. Copy [templates/adr/adr-template.md](../../templates/adr/adr-template.md) into `docs/adr/`.
2. Name it `<ID>-<slug>.md`, taking the next free number in increments of 10.
3. Fill in the metadata block and the six body sections.
4. Add a row to the appropriate category table above.
5. On Approval, populate the `related.adrs:` arrays in the Architecture documents and Standards it references.
