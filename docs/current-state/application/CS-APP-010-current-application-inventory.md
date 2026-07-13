---
id: CS-APP-010
title: Current Application Inventory
category: Application
status: Draft
gap_status: Diverges
confidence: High
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture:
    - APP-010
  standards:
    - ENG-050
    - ENG-060
    - SEC-010
    - OPS-050
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---

# CS-APP-010 — Current Application Inventory

## Scope

The actual observed internal shape of each deployed application. Does not describe the target pattern every application should follow (see `APP-010`).

## Method

Directory structure and `package.json` inspection of each of the four applications' repositories on the local machine.

## Inventory

| Application | Actual internal shape | Evidence |
|---|---|---|
| `socx-org-uk` | Monorepo: `apps/api` (Express), `apps/web` (React + Vite), `apps/worker` (Node) — three workspaces, no `packages/` shared-code folder | Observed |
| `ghs` | Monorepo: `apps/{api,web,worker}` **plus** `packages/{config,db,storage-client,types}` — shared code extracted into its own workspaces | Observed |
| `rms` | Monorepo: `apps/{api,web,worker}` plus `packages/{db,email}`; the `worker` app is Python, not Node, run via a separate virtualenv (`.venv_worker`) | Observed |
| `ams` | Monorepo: `apps/{api,web,worker}` plus `packages/{config,db,types}` — same shared-package shape as `ghs`, explicitly following patterns borrowed from `rms` per its own docs | Observed |

**Recurring pattern found across all four:** an `apps/{api,web,worker}` split is used by every application, and three of the four (`ghs`, `rms`, `ams`) additionally extract shared code into `packages/*`. This is real, pre-existing convergence toward something like `APP-010`'s layered pattern — it happened organically, not because `APP-010` mandated it (`APP-010` didn't exist yet).

**Where it diverges per app:**
- `socx-org-uk` has no `packages/` split — shared logic, if any, is not factored out.
- `rms`'s worker is a different language runtime (Python) from the other three apps' Node workers.
- Configuration loading, secrets handling, and logging conventions were not verified to be consistent across the four `apps/api` implementations beyond what's visible in their dependency lists (see `CS-TEC-010`) — actual code-level layering (interface vs. application vs. data-access separation, as `APP-010` describes) was **not inspected inside any `src/` directory**; this inventory only covers top-level repository shape, not internal code organization.

## Gap vs. Target Architecture

| Aspect | Current State | Target (`APP-010`) | Difference | Impact |
|---|---|---|---|---|
| Top-level layering | 3 of 4 apps already split `apps/` and `packages/` in a broadly similar way | A common three-layer pattern (interface / application / data access) | Directionally aligned at the repository-structure level; internal code-level layering unverified | Encouraging — retrofitting `APP-010` onto these apps may be smaller work than assumed, but this can't be confirmed without reading actual source files |
| Cross-app consistency | `socx-org-uk` doesn't follow the `packages/` convention the other three share | `APP-010` expects one common pattern | One of four apps is already an outlier | Worth deciding whether `socx-org-uk` should be brought in line, or whether it's simple enough (per its own README) not to need it |

## Related Documents

- Architecture: `APP-010`
- Standards: `ENG-050`, `ENG-060`, `SEC-010`, `OPS-050`
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none yet

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-13 | Initial draft | Socx |
