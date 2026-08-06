# Reference Implementations

Canonical, approved implementations demonstrating how the SOCX Engineering Standards and Architecture are realised in practice. Every asset in this library answers one question:

> **"What does a compliant implementation look like?"**

## Design Philosophy

Reference implementations are the *show, don't restate* layer of the engineering platform. A standard states what must be true; an architecture document describes the target design; an ADR records why a decision was made. A reference implementation **demonstrates** all three in working form — it links to them and never re-argues or restates their content.

How this library differs from its neighbours:

| Neighbour | Its question | The boundary |
|---|---|---|
| `templates/` | "Where do I start typing?" | A template is a blank scaffold to copy and fill in; a reference implementation is complete, opinionated, and working |
| `examples/` | "What does a finished *document* look like?" | Examples are worked instances of document types (a completed ADR, a populated runbook); reference implementations are configuration and code |
| `docs/runbooks/` | "How do I operate this right now?" | A runbook operates what a reference implements; procedure lives there, configuration lives here — neither restates the other |
| `docs/current-state/` | "What is actually deployed today?" | Current-State records observed reality, including where it drifts from this library; the reference is the measure, not the measurement |
| `scripts/` | "What automates this?" | Executable repo/operational tooling (Deliverable 8); a reference implementation may cite a script, never embed repo tooling |

Three rules govern everything here:

1. **No empty scaffolds.** An implementation reaches `Approved` only with recorded evidence that it has been exercised and works. Structure-without-content stays `Draft`, visibly. This rule exists because of a documented failure: `CS-INF-010` found a fully-planned infrastructure redesign whose config files were all present — and all **0 bytes**. Planned-but-empty must never again be mistakable for implemented.
2. **Canonical master, not runtime.** The live copy of any configuration runs in its consuming repository (`platform-infra`, application repositories). This library is what those copies are made from and measured against. Drift between a deployed copy and its reference is surfaced by the Current-State quarterly reviews; an *intentional* divergence requires an ADR, per the established rule.
3. **Complete and parameterised, never secret.** Assets are real, working configuration with substitution points marked `{{LIKE_THIS}}`. Concrete production values (hostnames, ports, paths) belong in the consuming repository. Secrets never appear anywhere, in any form (`SEC-010.1`).

## Identifiers

Reference implementations carry **no numbering scheme**. The directory path (`reference/nginx`, `reference/systemd`, …) is the permanent identifier and the citation form used everywhere — these paths are load-bearing (cited throughout the Standards, Architecture, and ADRs) and are never renamed. If a category later holds more than one distinct implementation, each becomes a descriptively named subdirectory (`reference/github/release/`) with its own manifest, still cited by path.

## Categories

| Path | Demonstrates | Realises | Key standards |
|---|---|---|---|
| `reference/systemd` | Direct-execution service and timer units (no `nvm` wrapping), credential loading | ADR-040, ADR-130 | OPS-030, OPS-040, OPS-060 |
| `reference/nginx` | Edge configuration: one site file per application, TLS baseline, correct proxy rules | ADR-050 | OPS-010; realises INF-010 |
| `reference/github` | CI/CD workflows and branch-protection configuration | ADR-150, ADR-170 | ENG-010, ENG-040 |
| `reference/security` | Secret handling: systemd credentials pattern, `.env` hygiene for development | ADR-130, ADR-110 | SEC-010 |
| `reference/terraform` | Provisioning droplet, DNS, and edge as code, including environment tiers | ADR-160, ADR-140 | OPS-010, OPS-020 |
| `reference/deployment` | Deploy/rollback glue connecting CI → droplet → systemd, health-gated restart | ADR-040, ADR-150 | OPS-030 |
| `reference/application` | Canonical three-layer Node/TS/Express service: layering, config-at-startup, structured logging, tests | ADR-060, ADR-070, ADR-090 | ENG-050, ENG-060, OPS-050 |
| `reference/monitoring` | Health-check endpoints and structured-logging configuration | ADR-040 | OPS-040, OPS-050 |

**Deferred (deliberately, per YAGNI):** `database/` (backup timers are systemd assets; provisioning is terraform), `api-contracts/` (belongs inside `application/` until cross-system calls exist — none do, per `CS-INT-010`), anything container-related (rejected by ADR-040).

## Lifecycle & Status

```
Draft  →  Approved  →  Deprecated
```

- A new implementation starts `status: Draft`.
- It moves to `status: Approved` **only when its `verified` field records real evidence** — how it was exercised, where, and when. This is the enforcement point of the no-empty-scaffolds rule, and it is mechanically checkable (no `Approved` without `verified`).
- A replaced implementation is marked `Deprecated` with a pointer to its successor in the manifest body; it is not deleted while anything still cites it.
- There are no per-manifest version numbers or revision-history tables — assets are consumed by copying, and "am I current?" is answered by git history.

**Ownership and review, library-wide:** all reference implementations are owned by Platform Engineering. There is no per-manifest review clock; an implementation MUST be re-verified when a related ADR or standard changes, and drift between deployed copies and the reference is detected by the Current-State quarterly reviews.

## Manifest Convention

Every reference implementation is a directory with a `README.md` manifest at its root, carrying exactly two frontmatter fields and five short sections:

```markdown
---
status: Draft          # Draft | Approved | Deprecated
verified: null         # "<how>, <where>, YYYY-MM-DD" — MUST be set before Approved
---

# reference/<category> — <Title>

## Purpose & Scope

What this demonstrates, and what it explicitly does not cover — naming the
document that owns anything adjacent (runbook, standard, architecture doc).

## Contents

| File | Role |
|---|---|
| `<file>` | <what it is> |

## Compliance

Only requirements the artefacts actually demonstrate, cited at requirement
level (never bare standard IDs):

| Requirement | Satisfied by |
|---|---|
| ENG-040.5 | `ci.yml` — defines the required pipeline stages |

## Usage

Parameters (`{{PLACEHOLDER}}` list) and the steps to copy/adapt into a
consuming repository, including how to re-verify after adapting.

## Related Documents

- Standards: …
- Architecture: …
- ADRs: …
- Current-State: …
- Runbooks: …
- Automation: …
```

## Cross-Referencing Conventions

- **Bidirectional at Approval.** When an implementation moves to `Approved`, the documents citing its path are updated: the "(currently empty)" annotations scattered across the Standards, Architecture, and ADRs are removed, and any missing `related.reference` entries are added.
- **Requirement-level compliance.** The Compliance table cites `SEC-010.3`, never bare `SEC-010`, so a review comment or CI message can point at the exact rule satisfied.
- **One home for content.** Configuration lives here; procedure lives in Runbooks; rules live in Standards; rationale lives in ADRs. Everything else is a link.

## Table of Contents

Implementation order follows the approved Deliverable 6 sequencing — the first three retire risks that Current-State documented as live.

| # | Path | Title | Status |
|---|---|---|---|
| 1 | `reference/systemd` | Service & Timer Units | Approved |
| 2 | `reference/nginx` | Edge & Site Configuration | Approved |
| 3 | `reference/github` | CI/CD Workflows & Branch Protection | Draft |
| 4 | `reference/security` | Secret Handling (systemd credentials) | Draft |
| 5 | `reference/terraform` | Infrastructure as Code | Draft |
| 6 | `reference/deployment` | Deploy & Rollback Glue | Draft |
| 7 | `reference/application` | Canonical Three-Layer Service | Planned |
| 8 | `reference/monitoring` | Health Checks & Logging Configuration | Planned |

Status is one of `Planned`, `Draft`, `Approved`, `Deprecated` — the authoritative status for an implementation is the `status` field in its own manifest; this column is kept in sync as a convenience index.

## Authoring a New Reference Implementation

1. Create (or enter) the category directory under `reference/`.
2. Write the manifest `README.md` using the skeleton above — there is deliberately no `templates/reference/`; this section is the single source for the convention, and the first Approved manifest serves as the living example.
3. Add the working, parameterised artefacts alongside it.
4. Keep `status: Draft` until the implementation has been exercised; record the evidence in `verified`, then move to `Approved`.
5. On Approval, update the citing documents (cross-referencing conventions above) and the Table of Contents row here.
