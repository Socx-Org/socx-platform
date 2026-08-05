---
id: CS-TEC-010
title: Current Technology Inventory
category: Technology
status: Approved
gap_status: Diverges
confidence: High
owner: Platform Engineering
version: "2.1"
last_reviewed: 2026-08-06
review_cycle: quarterly
related:
  architecture:
    - TEC-010
  standards: []
  adrs:
    - ADR-180
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---
# CS-TEC-010 — Current Technology Inventory

## Scope

Actual technology and versions currently in use across the platform's repositories, and how each was confirmed. Does not restate the approved/proposed stack (see `TEC-010`).

## Method

Read directly from each repository's `package.json`, README, and `.github/workflows/` on the local machine. No SSH access to the production droplet — actual *installed* versions on the live server are not confirmed, only what each repository's manifest declares as its dependency.

## Inventory

**Platform transition (2026-07-15, `ADR-180`):** the droplet this inventory's deployment-derived rows described has been decommissioned; the new host has **no technology installed yet** (`CS-INF-020`). Repo-derived rows (frameworks, databases-as-declared, password hashing, CI workflows) are unchanged — the repositories still exist as code. The Hosting row below now describes the new host; other deployment references (e.g. `platform-infra` structure) are retained as repo-level observations.

| Layer                           | Technology (observed)                                                                                                                                                                     | Where observed                                                                                                                                  | Source                       | Evidence                                                                                                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Hosting                         | DigitalOcean, single droplet, Ubuntu 26.04 LTS (rebuilt 2026-08-06, same reserved IP) — **fresh host, nothing deployed** (`ADR-180`)                                                                                          | `CS-INF-020` (provisioning attestation + DNS observation)                                                                                     | Attestation + DNS            | Attested / Observed (DNS)                                                                                                          |
| Reverse proxy                   | nginx                                                                                                                                                                                     | `platform-infra/nginx/` structure; `deployment-architecture.md`                                                                             | Config file structure        | Observed (structure); actual directives Unknown — site config files are present but currently**empty (0 bytes)**            |
| Process management              | systemd (target);`nvm`-wrapped systemd `ExecStart` (as currently run, per audit)                                                                                                      | `platform-infra/systemd/`; `deployment-architecture.md` §"Principle 6"                                                                     | Docs + config file structure | Observed (structure); actual unit file content Unknown — all systemd service files present are currently**empty (0 bytes)** |
| CI/CD                           | GitHub Actions                                                                                                                                                                            | `ghs/.github/workflows/ci.yml` (10,947 bytes), `rms/.github/workflows/ci.yml` (8,341 bytes)                                                 | GitHub Actions workflow file | Observed                                                                                                                           |
| API framework —`ghs`         | Express 4.21.2, TypeScript                                                                                                                                                                | `ghs/apps/api/package.json`                                                                                                                   | package.json                 | Observed                                                                                                                           |
| API framework —`rms`         | Express 5.0.0, Prisma ORM 5.x                                                                                                                                                             | `rms/apps/api/package.json`, `rms/README.md`                                                                                                | package.json + README        | Observed                                                                                                                           |
| API framework —`ams`         | Express 5.1.0, TypeScript                                                                                                                                                                 | `ams/apps/api/package.json`                                                                                                                   | package.json                 | Observed                                                                                                                           |
| API framework —`socx-org-uk` | Express 4.21.2                                                                                                                                                                            | `socx-org-uk/apps/api/package.json`                                                                                                           | package.json                 | Observed                                                                                                                           |
| Database                        | PostgreSQL —`ghs` via raw `pg` driver 8.21.0; `rms` via Prisma, PostgreSQL 16 explicitly stated; `ams` via its own `packages/db` (Prisma-style, not inspected in depth)        | Respective`package.json` files, `rms/README.md`                                                                                             | package.json + README        | Observed                                                                                                                           |
| Cache / queue                   | Redis —`ghs` via `redis` 4.7.0 (cache); `ams` via `ioredis` 5.4.2 + `bullmq` 5.51.1 (job queue)                                                                                | Respective`package.json` files                                                                                                                | package.json                 | Observed                                                                                                                           |
| Password hashing                | **Three different libraries across three apps**: `ghs` → `bcryptjs` (pure JS); `rms` → `bcrypt` (native); `ams` → `argon2`                                           | Respective`package.json` files                                                                                                                | package.json                 | Observed                                                                                                                           |
| Auth token                      | JWT (`jsonwebtoken`) in `ghs`, `rms`, `ams` — each independently                                                                                                                 | Respective`package.json` files                                                                                                                | package.json                 | Observed                                                                                                                           |
| Worker runtime                  | `rms` uses a **separate Python 3.12 + APScheduler** worker alongside its Node API; `ghs` and `ams` workers are Node-only                                                      | `rms/README.md`; `platform-infra/systemd/services/rms-worker-py.service` (filename only, empty content)                                     | README + service filename    | Observed                                                                                                                           |
| 2FA                             | `ams` implements TOTP 2FA (`otplib`, `qrcode`)                                                                                                                                      | `ams/apps/api/package.json`                                                                                                                   | package.json                 | Observed                                                                                                                           |
| Logging                         | `ams` uses structured logging (`winston` + daily rotate); no evidence found of structured logging in `ghs`, `rms`, or `socx-org-uk` manifests                                   | `ams/apps/api/package.json`                                                                                                                   | package.json                 | Observed (for`ams`); Unknown for the other three                                                                                 |
| API documentation               | `rms` has a committed OpenAPI spec (`rms_openapi_v1.1.yaml`); `ams` has Swagger tooling as a dependency (`swagger-jsdoc`, `swagger-ui-express`) but no spec file confirmed read | `rms/infra/`; `ams/apps/api/package.json`                                                                                                   | File presence + package.json | Observed                                                                                                                           |
| Infrastructure as code          | `ghs` contains an `infra/terraform` directory                                                                                                                                         | `ghs/infra/terraform` (contents not read)                                                                                                     | Directory presence           | Observed (exists); Unknown whether it's actually applied to any real infrastructure                                                |

**Significant finding:** `TEC-010` (architecture) lists "Application language/framework," "Primary data store," and "Identity provider" as `Under Evaluation`. This inventory shows they are **not** under evaluation — each application already made independent, divergent choices (different password-hashing libraries, `pg` vs. Prisma, Node-only vs. Node+Python workers). Recommend `TEC-010` be revisited using this evidence; not performed here, as it would require editing an Approved architecture document.

## Gap vs. Target Architecture

| Aspect                                    | Current State                                                                                                                                                | Target (`TEC-010`)                                                           | Difference                                                                                                                             | Impact                                                                                                                                                        |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hosting/proxy/CI                          | DigitalOcean + nginx + GitHub Actions confirmed                                                                                                              | `Proposed` (inferred, unconfirmed)                                           | Current state confirms these rows                                                                                                      | Recommend`TEC-010` move these three rows from `Proposed` to `Approved` once backed by an ADR                                                            |
| Process management                        | Nothing running — the old `nvm`-wrapped units were retired with the droplet (`ADR-180`); the target is `reference/systemd`'s direct-execution pattern | `Approved` (systemd, per `ADR-040`)                                          | New host has no units installed yet                                | The known `nvm` fragility is eliminated by decommissioning rather than remediation; the rebuild installs the clean pattern directly                        |
| App language/data store/identity provider | Decided independently per app, and divergent (three password libraries, two ORMs/drivers)                                                                    | `Under Evaluation` — implies a single platform-wide answer is still pending | The premise of a single upcoming decision no longer matches reality — three real decisions already exist and disagree with each other | Any future platform-wide standardization (e.g. picking one password-hashing library) is now a migration across three live codebases, not a green-field choice |

## Related Documents

- Architecture: `TEC-010`
- Standards: none directly — informs future standards work rather than satisfying one
- ADRs: none yet — every technology choice found here predates this handbook and has no recorded rationale
- Reference Implementations: none in `reference/`; the closest real equivalent is `platform-infra` itself, which is a separate repository, not this repository's `reference/` folder
- Runbooks: none in this repository

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
| 2.0     | 2026-07-15 | Platform transition (ADR-180): hosting/process rows updated for the fresh host; repo-derived rows unchanged | Socx   |
| 2.1     | 2026-08-06 | Droplet rebuilt a second time (Ubuntu 24.04 → 26.04 LTS, same IP) before bootstrap execution | Socx   |
