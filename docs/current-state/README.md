# Current State

As-is documentation: what is actually deployed and running today.

Content here describes the platform as it currently exists — current infrastructure, current service topology, current known gaps — regardless of whether that matches the intended design in [docs/architecture](../architecture).

When the two diverge, that divergence is itself worth recording here (and, if the divergence is intentional, in an ADR under [docs/adr](../adr)).

## Scope

A current-state document records what actually exists and its observed configuration, as of a specific date. It does not restate:

- **what** the target design is (that's Architecture)
- **what** every project MUST do (that's an Engineering Standard)
- **why** a specific decision was made (that's an ADR)
- **what** a compliant implementation looks like, in the abstract (that's a Reference Implementation)
- **how to operate, remediate, or respond to** anything (that's a Runbook)

A current-state document MUST link to the relevant architecture document, standard, ADR, reference implementation, or runbook rather than duplicating its content.

**Boundary with Runbooks, stated explicitly:** a current-state document records that something exists and its observed configuration — never how to operate, remediate, or respond to it. For example, `CS-INF-010` may record that a scheduled job exists and what it runs; it must not describe how to restart it or respond to its failure. That belongs in a Runbook, linked from `Related Documents`, not restated here.

## Inventory Principles

- **Record facts, not intentions.** If it isn't true right now, it doesn't belong here, even if it's about to become true.
- **Always cite provenance.** Every document has a `Method` section (and, where useful, a per-row `Source`); an unverified claim is marked `confidence: Low`, not omitted.
- **Never restate — cite and diff.** Architecture, Standards, ADRs, Reference Implementations, and Runbooks are all linked, never duplicated.
- **Stale is worse than missing.** A document with an old `last_reviewed` is a liability, not a placeholder — that's why `review_cycle` defaults shorter here than in Standards or Architecture.
- **Concrete detail belongs here.** Hostnames, versions, ports, account names — this is the one place in the handbook where that's the point, not a violation (the opposite of Architecture's `INF-010`, which must stay conceptual).

## Separation of Concerns

| Concern | Lives in | Answers |
|---|---|---|
| Architecture | `docs/architecture/` | What the target design is, and why |
| Current State | `docs/current-state/` | What is actually deployed today |
| Engineering Standards | `docs/standards/` | What every project MUST do |
| ADRs | `docs/adr/` | Why a specific decision was made |
| Reference Implementations | `reference/` | What a compliant implementation looks like |
| Runbooks | `docs/runbooks/` | How to operate / respond right now |

## Document Lifecycle

Current-state documents follow their own lifecycle, independent of the Engineering Standards Handbook's `GEN-010` — same reasoning as Architecture: `GEN-010` governs rules projects must follow, not how this repository manages its own documentation.

- A new document starts `status: Draft`, `version: "0.1"`, `gap_status: Not yet assessed`, `confidence: Low`.
- It moves to `status: Approved`, `version: "1.0"` only after the inventory has been verified, not merely drafted.
- Once Approved, its `id` is permanent — never reused or renumbered.
- A revision increments `version`: **minor** for a factual update that doesn't change the `gap_status` conclusion, **major** when `gap_status` itself changes (newly `Aligned`, or newly `Diverges`) — version history should track whether the compliance/alignment story changed, which is the single most useful signal this document type can carry.
- `status: Deprecated` has two distinct meanings here, unlike Architecture: either the document is superseded by a refreshed inventory (`superseded_by` set), **or** the system it described has been decommissioned and no longer exists (`superseded_by: null`, retained for historical record).
- Every document is reviewed at least once per its stated `review_cycle` (default **quarterly** — shorter than Standards' or Architecture's annual default, since facts drift faster than rules or intent), updating `last_reviewed` even with no changes.

There is no `Exceptions` mechanism here, same as Architecture — this content is neither a rule to be excepted from nor a design to be deviated from, only a fact to be corrected if wrong.

## Numbering Scheme

Each document has a permanent ID: `CS-<CATEGORY>-<NUMBER>`, e.g. `CS-CTX-010`.

- The `CS-` prefix plus category code mirrors the corresponding Architecture document's category one-for-one (`CS-CTX-010` is the as-is counterpart of `CTX-010`) — deliberately, so the pairing is structural rather than something maintained by prose cross-references.
- Numbers start at `010` and increment by `10` within each category, same rule as Standards and Architecture.
- Filenames are ID-prefixed (`CS-CTX-010-current-platform-context.md`) so a directory listing is self-ordering and self-documenting.
- No requirement-level sub-numbering (no `CS-CTX-010.1`) — this content is descriptive, not normative.
- **One exception:** `REP-010` (Repository Inventory) does not carry the `CS-` prefix and has no Architecture counterpart to mirror — see Categories below.

## Categories

| Code | Category | Scope |
|---|---|---|
| REP | Repository | Which repositories exist, their purpose, and their engineering-governance metadata. Standalone — no Architecture counterpart. |
| CS-CTX | Context | Who or what actually interacts with the platform today |
| CS-DOM | Domain | Which systems are actually deployed and live right now |
| CS-APP | Application | The actual observed internal shape of each deployed application |
| CS-DAT | Data | Actual data stores and their actual retention/backup configuration |
| CS-INT | Integration | Actual integrations that exist between systems today |
| CS-TEC | Technology | Actual technology and versions currently running, and how each was observed |
| CS-INF | Infrastructure | Actual DNS, TLS, reverse proxy, firewall, system services, scheduled jobs, and storage — concrete, unlike `INF-010` |
| CS-IAM | Identity | Actual accounts and the actual trust/auth mechanism in use today |

## What Each Document Answers

| Document | Question it answers |
|---|---|
| `REP-010` | Which repositories exist, what are they for, and who owns them? |
| `CS-CTX-010` | Who or what actually interacts with the platform today? |
| `CS-DOM-010` | Which systems are actually deployed and live right now? |
| `CS-APP-010` | What is each deployed application's actual internal shape? |
| `CS-DAT-010` | What data stores actually exist, and how are they actually retained/backed up? |
| `CS-INT-010` | What integrations actually exist between systems today? |
| `CS-TEC-010` | What technology and versions are actually running, and how do we know? |
| `CS-INF-010` | What does the actual infrastructure look like — DNS, TLS, proxy, firewall, services, jobs, storage? |
| `CS-IAM-010` | Who actually has access today, and how is trust actually established? |

## Table of Contents

| ID | Title | Status | Gap Status | Confidence |
|---|---|---|---|---|
| `REP-010` | Repository Inventory | Planned | N/A — no architecture counterpart | — |
| `CS-CTX-010` | Current Platform Context | Planned | Not yet assessed | — |
| `CS-DOM-010` | Current System Landscape | Planned | Not yet assessed | — |
| `CS-APP-010` | Current Application Inventory | Planned | Not yet assessed | — |
| `CS-DAT-010` | Current Data Inventory | Planned | Not yet assessed | — |
| `CS-INT-010` | Current Integration Inventory | Planned | Not yet assessed | — |
| `CS-TEC-010` | Current Technology Inventory | Planned | Not yet assessed | — |
| `CS-INF-010` | Current Infrastructure Inventory | Planned | Not yet assessed | — |
| `CS-IAM-010` | Current Identity & Access Inventory | Planned | Not yet assessed | — |

Status is one of `Planned`, `Draft`, `Approved`, `Deprecated` — the authoritative status for a given document is the `status` field in its own metadata, not this table; this column (and Gap Status, and Confidence) is kept in sync as a convenience index.

## Diagrams

Diagram source files live in [docs/diagrams](../diagrams), not in a nested `docs/current-state/diagrams/` — same cross-cutting pool shared by Architecture, Runbooks, and ADRs. A diagram is ID-prefixed with the document that owns it (e.g. `docs/diagrams/CS-INF-010-current-infrastructure-topology.mmd`) and is embedded or linked from that document, never copied into it.

## Authoring a New Current-State Document

1. Copy [templates/current-state/current-state-doc-template.md](../../templates/current-state/current-state-doc-template.md) into the appropriate category folder under `docs/current-state/`.
2. Name it `<ID>-<slug>.md`.
3. Fill in the metadata block and body, including a `Method` section describing how the facts were gathered.
4. Add a row to the Table of Contents above.
