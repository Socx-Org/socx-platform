---
id: CTX-010
title: Platform Context
category: Context
status: Draft
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: annual
related:
  standards:
    - OPS-010
  adrs: []
  reference:
    - reference/deployment
    - reference/nginx
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# CTX-010 — Platform Context

## Scope

The boundary of the SOCX platform: which systems are in scope, who or what interacts with them from outside, and why the platform exists. Does not describe how the systems relate to each other internally (see `DOM-010`) or any system's internal design (see `APP-010`).

## Context

`socx-platform` is the engineering source of truth for a small set of related application repositories — `socx-org-uk`, `ghs`, `rms` — fronted by shared infrastructure (`do-nginx-infra`). This document exists so anyone joining the platform can see the whole boundary in one place before going system-by-system.

**Open item:** the business purpose of each system (`socx-org-uk`, `ghs`, `rms`) and the identity of external actors (staff, customers, the public, other services) is not yet recorded anywhere in this repository. The diagram and actor list below are placeholders — confirm and replace before this document is Approved.

## Target Design

```mermaid
flowchart LR
    actor["External actor(s)\n(TBD — confirm)"] -->|HTTPS| edge["Shared edge\n(do-nginx-infra)"]
    edge --> socx["socx-org-uk"]
    edge --> ghs["ghs"]
    edge --> rms["rms"]
```

Diagram source: `docs/diagrams/CTX-010-platform-context.mmd`.

- All external traffic enters through the shared nginx edge (`do-nginx-infra`), not directly against any application — see `INF-010` for the target topology this implies.
- Each of `socx-org-uk`, `ghs`, and `rms` is a distinct system with its own repository; `socx-platform` itself contains no application code (per the project charter) and is not a runtime participant in this diagram.
- External actors are not yet enumerated — this needs input on who/what actually calls these systems (end users, internal staff, other automated services) before the diagram is more than a placeholder.

## Current-State Gap

Not yet assessed — no corresponding `docs/current-state/` document exists yet to compare against.

## Related

- Standard(s) this design satisfies: `OPS-010` (environment boundary implied by the shared edge)
- ADR(s) behind this design: none yet
- Reference implementation(s): `reference/deployment`, `reference/nginx` (both currently empty)
- Runbook(s): none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
