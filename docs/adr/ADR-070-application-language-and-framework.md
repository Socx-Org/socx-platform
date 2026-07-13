---
id: ADR-070
title: Application language & framework
status: Approved
category: Application
version: "1.0"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture:
    - APP-010
    - TEC-010
  standards:
    - ENG-020
    - ENG-030
  current_state:
    - CS-TEC-010
  reference: []
  runbooks: []
  adrs: []
supersedes: []
superseded_by: null
---

# ADR-070 — Application language & framework

## Context

`APP-010` defines a deliberately language-agnostic three-layer application pattern, and `TEC-010` still lists "Application language/framework" as `Under Evaluation`. The current-state inventory contradicts the "under evaluation" premise: this is not a green-field choice.

Per `CS-TEC-010`, every application already runs the same core stack:

- `ghs` — Express 4.21.2, TypeScript
- `rms` — Express 5.0.0 (plus a separate Python 3.12 + APScheduler worker)
- `ams` — Express 5.1.0, TypeScript
- `socx-org-uk` — Express 4.21.2

The de-facto platform stack is therefore **Node.js + TypeScript + Express**. What is genuinely undecided is not *whether* to use it but whether to *ratify* it, and how to resolve two real inconsistencies the inventory surfaced: a split between Express 4 and Express 5, and the Python worker in `rms` that sits outside the Node stack.

## Decision

The platform adopts **Node.js + TypeScript + Express** as the approved application language and framework for all SOCX services, making `TEC-010`'s row `Approved`. Specifically:

1. Node.js + TypeScript + Express is the standard stack; new services start from it, and `APP-010`'s language-agnostic three layers are realised in it.
2. Services converge on a single version baseline — the latest Express major (currently Express 5, already used by `rms` and `ams`), a current Node LTS line, and a current TypeScript line. Bringing `ghs` and `socx-org-uk` (Express 4) onto that baseline is tracked migration work, not a blocker to this decision.
3. The `rms` Python 3.12 + APScheduler worker is recorded as an explicit, bounded exception — a scheduled-work runtime — not a second general-purpose application stack.

The ORM / data-access approach is **not** settled here — it is deferred to `ADR-090`, where the `pg`-vs-Prisma divergence is addressed alongside the datastore.

## Alternatives Considered

- **Ratify the de-facto Node.js + TypeScript + Express stack — selected.** Lowest cost; formalises what all four applications already do and lets `ENG-020`/`ENG-030` tooling target one ecosystem.
- **Standardise on a different single stack** — Rejected as disproportionate: it would force a rewrite or migration of four live applications for no evidenced benefit.
- **Remain explicitly polyglot (no platform standard)** — Rejected: it forfeits the shared-tooling and mobility benefits `APP-010` exists to create, and lets divergence (already visible in worker runtimes) grow unchecked.
- **Express 4 vs Express 5 as the baseline** — resolved in favour of the latest major (Express 5); the two Express 4 apps converge onto it as tracked migration work.

## Consequences

- Ratifying the de-facto stack turns an "open evaluation" into a settled baseline, unblocking the Reference Implementations deliverable (a canonical Node/TS/Express service) and the CI/CD templates under `ENG-040`.
- A version baseline converts the Express 4/5 split from silent drift into a tracked, scheduled convergence.
- Treating the Python worker as a named exception keeps the standard honest rather than pretending the platform is single-runtime.
- Any future move away from this stack becomes a multi-repository migration, not a green-field choice — an argument for recording the baseline now while it is still cheap to state.

## Related Documents

- Architecture: `APP-010`, `TEC-010`
- Standards: `ENG-020` (code quality), `ENG-030` (testing)
- Current-State documentation: `CS-TEC-010`
- Reference Implementations: none yet — a canonical service would realise this decision
- Runbooks: none
- ADRs: `ADR-090` (datastore & data-access, where the ORM split is resolved)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-14 | Approved      | Socx   |
