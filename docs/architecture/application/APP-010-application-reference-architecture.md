---
id: APP-010
title: Application Reference Architecture
category: Application
status: Approved
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - ENG-050
    - ENG-060
    - SEC-010
    - OPS-050
  adrs: []
  reference: []
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# APP-010 — Application Reference Architecture

## Scope

The internal architecture pattern every SOCX application (`socx-org-uk`, `ghs`, `rms`, and any future system) is expected to target. This is a **shared pattern**, not a description of any single application's actual internals — a specific application's real internal design, once it exists, is documented in that application's own repository and should reference this document as its baseline rather than duplicating it here.

## Context

Without a shared internal pattern, each application tends to invent its own layering, its own place for configuration, and its own way of wiring in logging and secrets — which then has to be relearned per project. A single reference pattern lets `ENG-050` (Repository Structure) and `ENG-060` (Naming Conventions) be checked mechanically, and lets a contributor move between applications without re-deriving how each one is put together.

## Target Design

A SOCX application targets three internal layers, regardless of language or framework:

1. **Interface layer** — exposes the application's functionality (HTTP API, scheduled job entry points, etc.). Owns request/response shape and input validation. Talks to the application layer only — never directly to persistence.
2. **Application layer** — business logic and orchestration. Contains no framework- or transport-specific code, so it can be tested without spinning up the interface layer.
3. **Data access layer** — the only layer permitted to talk to persistence (per `DAT-010`, using the technology recorded in `TEC-010`). Exposes a narrow interface to the application layer rather than leaking storage-specific detail upward.

Cross-cutting concerns are wired at the edges of these layers, not scattered through them:

- Configuration and secrets are read once at startup, from the mechanism required by `SEC-010`, and passed down — application code does not read environment variables directly deep in the call stack.
- Logging follows `OPS-050` (structured, no secrets) and is emitted from each layer at its own boundary, not only from the interface layer.
- On disk, this maps to `ENG-050`'s required top-level split: interface and application-layer code under the project's `src/`, tests under `tests/`, infrastructure/deployment config under `deploy/`.

## Current-State Gap

Not yet assessed — no application in the platform has been checked against this pattern yet.

## Related Documents

- Standards: `ENG-050`, `ENG-060`, `SEC-010`, `OPS-050`
- ADRs: none yet
- Reference Implementations: none yet
- Runbooks: none yet
- Current-State documentation: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
| 1.0 | 2026-07-13 | Approved | Socx |
