---
status: Approved
verified: "On-host, real droplet (prod-lab-01): deployed as a disposable canary-app service via reference/deployment's real deploy-release.sh, running under a real reference/systemd-pattern unit, reading db_password via a real LoadCredential=, against a real PostgreSQL 16 database (schema.sql applied for real). Real HTTP traffic confirmed end-to-end: GET /healthz, POST /widgets creating a real row, GET /widgets reading it back. Deliberately broken and rolled back twice (automatic and explicit) as part of reference/deployment's verification, then redeployed clean. Not run through reference/nginx's edge -- direct-to-droplet only, a deliberate scope boundary (see Purpose & Scope). Torn down after. 2026-08-07"
---

# reference/application — Canonical Three-Layer Service

## Purpose & Scope

A working Node.js + TypeScript + Express service realising `APP-010`'s three-layer pattern (`ADR-060`) in the stack `ADR-070` ratified, against the datastore `ADR-090` ratified — the concrete answer to "what does a compliant SOCX application actually look like?"

**What `verified` covers, and what it deliberately doesn't.** This service was actually deployed to the real droplet — via `reference/deployment`'s real scripts, under a real systemd unit, against a real Postgres database, with real HTTP traffic proving the whole chain (config → credentials → data access → application → interface) works together, not just each layer in isolation. It was **not** wired through `reference/nginx`'s edge: doing so would have meant provisioning a new DNS record and a new Let's Encrypt certificate for a disposable canary, a materially bigger footprint than the exercise warranted, and `reference/nginx`'s edge behavior is already separately Approved and verified — reusing this canary to re-prove it would add nothing. Anyone adapting this service for real, internet-facing use still needs to point a `reference/nginx` site config at it.

Explicitly not covered here:

- **The ORM/data-access-tooling decision** — `ADR-090` explicitly defers Prisma-vs-raw-`pg`-vs-both to a future ADR. This service uses the raw `pg` driver precisely because that's the lowest-common-denominator choice that doesn't presume an unmade decision — adopting Prisma here would quietly settle something still open.
- **Health-check *pattern* and monitoring/log-aggregation configuration** — `GET /healthz` exists here because `OPS-040.1` requires every production service to expose *something*, but readiness checks, dependency probes, and the broader monitoring/log-shipping pattern are `reference/monitoring` (Deliverable 6.9).
- **Deploy mechanics, systemd units, edge config** — already built and Approved (`reference/deployment`, `reference/systemd`, `reference/nginx`); this service's `dist/index.js` output path is deliberately shaped to match `reference/systemd`'s existing `ExecStart` exactly, not re-specify it.
- **Authentication/authorization** — no ADR has settled an approach yet (`ADR-120`'s identity provider doesn't exist as a concrete product); inventing one here would misrepresent a platform decision as already made.
- **Code-quality tooling / linting** — `ENG-020` governs this and isn't ratified with a specific linter config; `reference/github`'s `ci.yml` already runs `lint --if-present`, so its absence here is not a gap this implementation is responsible for.

## Contents

| File | Role |
|---|---|
| `package.json` | Workspace root (`workspaces: ["apps/*"]`) |
| `package-lock.json` | Committed for reproducible installs — `reference/github`'s `ci.yml` runs `npm ci`, which requires one |
| `apps/api/package.json`, `tsconfig.json`, `tsconfig.build.json` | The one workspace this reference implementation provides — build/test/typecheck configuration |
| `apps/api/src/config.ts` | Loads configuration and secrets once at startup (`APP-010`, `ADR-130`) |
| `apps/api/src/logger.ts` | Structured JSON logger, no dependency (`OPS-050`) |
| `apps/api/src/data/` | Data-access layer — `pool.ts`, `widgets.repository.ts`, `schema.sql` — the only code permitted to touch persistence |
| `apps/api/src/application/widgets.service.ts` | Application layer — business logic, no transport-specific code |
| `apps/api/src/interface/http/` | Interface layer — Express app, routes, request validation |
| `apps/api/src/index.ts` | Composition root — wires config → data → application → interface, in that order |
| `apps/api/tests/widgets.service.test.ts` | Unit test — application layer against a fake repository |
| `apps/api/tests/widgets.repository.integration.test.ts` | Integration test — data-access layer against a real Postgres |
| `deploy/README.md` | Pointer only — `ENG-050.4`'s required top-level `deploy/` directory, deliberately not duplicating `reference/systemd`/`nginx`/`deployment`/`github` |

## Design Decisions

- **Input validation lives in the interface layer, not the application layer.** `ADR-060` states this explicitly — the widgets route rejects a missing/empty `name` with `400` before the application layer ever sees it; `widgets.service.ts` trusts its caller and contains no shape-checking of its own.
- **Raw `pg`, not Prisma.** `ADR-090` names the ORM choice as a deferred, future decision. Using `pg` directly is the one choice that doesn't accidentally pre-empt it.
- **Config and secrets are read exactly once, in `index.ts`, and passed down as typed objects.** No module below the composition root reads `process.env` or a credential file directly (`APP-010`'s explicit requirement) — `data/pool.ts` receives a `DatabaseConfig` value, never touches `process.env` itself.
- **The database password is read via `LoadCredential=`, matching `reference/systemd` exactly.** `config.ts` reads `$CREDENTIALS_DIRECTORY/db_password` when set (production, `ADR-130`) and falls back to a `DB_PASSWORD` env var otherwise (local development, `reference/security`'s `.env` pattern) — same credential name (`db_password`) `reference/systemd`'s `app-api.service` already declares via `LoadCredential=`.
- **Build output is named `index.ts` → `dist/index.js` deliberately.** `reference/systemd`'s already-Approved `app-api.service` hardcodes `ExecStart={{APP_DIR}}/current/apps/api/dist/index.js` — this was caught and fixed during authoring (the source file was originally `server.ts`, which would have shipped a service that couldn't actually start under the existing unit).
- **A minimal hand-written structured logger, not a third-party logging library.** No ADR has ratified one; `console`-adjacent JSON-to-stdout is enough to satisfy `OPS-050.1`/`.2` without presuming a dependency choice nobody has made.
- **No third-party test framework.** `node:test`/`node:assert` (built into the confirmed Node runtime, `CS-INF-020`) — `ENG-030` deliberately does not mandate one, so adding a dependency here would set a precedent this document has no authority to set.
- **The integration test requires a real Postgres — no mock fallback.** Per `ENG-030.4`; `reference/github`'s `ci.yml` already provisions exactly this via its `services.postgres` block, so `npm test --workspaces` works unmodified in CI.
- **A single `apps/api` workspace, npm workspaces.** Matches the real, observed pattern across `ghs`/`rms`/`ams` (`CS-APP-010`) and the exact commands `reference/github`'s `ci.yml` already runs (`--workspaces --if-present`) — adding a `worker` workspace is a real future extension, not fabricated here since this resource needs no background job.
- **The full set of `Environment=` variables a real unit must set is now explicit (Usage), not left implicit.** Found during on-host verification: `reference/systemd`'s generic `app-api.service` template only shows `SOCX_ENV`/`PORT` — it predates this service and has no way to know `config.ts` also needs `SERVICE_NAME`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`. `config.ts` correctly refused to guess any of them (falling back to the literal, obviously-invalid `{{APP_NAME}}` string rather than fabricating a real-looking default), which surfaced the gap immediately as a clean `password authentication failed` error rather than a silent misconfiguration — but nothing previously told an adopter these five variables need setting. They're listed explicitly in Usage now.

## Compliance

| Requirement | Satisfied by |
|---|---|
| ENG-050.2 | `apps/api/src/` — all source under one dedicated directory |
| ENG-050.3 | `apps/api/tests/` — a single, clearly named test location |
| ENG-050.4 | `deploy/` — dedicated top-level directory, separate from source |
| ENG-060.3 | `config.ts`'s env vars (`DB_HOST`, `DB_PORT`, `SOCX_ENV`, …) — `UPPER_SNAKE_CASE` |
| ENG-030.3 | `widgets.service.test.ts` — unit test for business logic, no HTTP/DB |
| ENG-030.4 | `widgets.repository.integration.test.ts` — runs against a real Postgres, not a mock |
| ENG-030.6 | `npm test` — a single local command, identical to what CI runs |
| OPS-050.1 | `logger.ts` — every log line is a single JSON object |
| OPS-050.2 | `logger.ts` — every entry carries `timestamp` (UTC), `level`, `service` |
| OPS-050.3 | `app.ts`'s error handler — logs `err.message` only, never the raw request body |
| SEC-010.3 | `config.ts`'s `readSecret()` — production path is `LoadCredential=` via `$CREDENTIALS_DIRECTORY`, never hardcoded |
| SEC-010.5 | Verified locally: a real DB connection failure surfaces as a generic `{"error":"internal server error"}` to the client; the password never appears in the logged error or the response |

**Not satisfied by this artefact:** `OPS-050.6` (central log aggregation) — logs go to stdout/journald here; shipping them off-host is `reference/monitoring`'s concern.

## Prerequisites

- Node.js `>= 24` (`ADR-070`) — confirmed running for real as `v24.19.0` on the droplet during on-host verification, matching `CS-INF-020` exactly
- PostgreSQL reachable at `DATABASE_URL` (tests) or `DB_HOST`/`DB_PORT`/`DB_NAME`/`DB_USER`/`db_password` (runtime) — `ADR-090`
- For production: `reference/systemd`'s credentials directory already provisioned, with `db_password` written via `reference/security`'s `set-credential.sh`

## Usage

Parameters: `{{APP_NAME}}` (used throughout `config.ts`'s defaults and `reference/systemd`'s unit — the `package.json` `name` fields use a literal placeholder-free name instead, since `npm` validates package names and rejects `{{...}}` syntax; rename them directly).

1. Copy this directory into a new or existing repository, substituting `{{APP_NAME}}` in `config.ts` and renaming the `package.json` `name` fields.
2. `npm install` at the workspace root.
3. Apply `apps/api/src/data/schema.sql` to the target database (manually, or via the consuming project's chosen migration tool — not decided here).
4. Local development: `npm run dev --workspace apps/api` with `DB_PASSWORD` set via `reference/security`'s `.env` pattern.
5. `npm test --workspaces --if-present` — requires a reachable Postgres for the integration test (see `reference/github`'s `ci.yml` for the CI-side service container).
6. `npm run build --workspaces --if-present` — produces `apps/api/dist/index.js`, the exact path `reference/systemd`'s `app-api.service` already expects.
7. **In the consuming project's `reference/systemd` unit, set these `Environment=` lines** — `config.ts` requires them and deliberately does not guess any of them: `SERVICE_NAME`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` (plus the unit template's own `SOCX_ENV`/`PORT`). Missing one fails loudly and specifically (e.g. a real Postgres authentication error naming the exact wrong value), not silently.
8. Re-verify after adapting anything under `apps/api/src/`: deploy for real via `reference/deployment`, running under `reference/systemd`, against a real Postgres. Update this manifest's `verified` field to reflect the new evidence.

## Expected Adaptations

**Consuming projects are expected to customise:**

- The `widgets` resource itself — a stand-in to prove the pattern; a real service replaces it with its actual domain
- `package.json` `name` fields, `{{APP_NAME}}` substitutions
- Additional workspaces (`apps/worker`, `packages/*`) once a project actually needs them
- The ORM/data-access approach, once the deferred `ADR-090` follow-up settles it

**Must remain unchanged to preserve compliance:**

- Input validation in the interface layer, not the application layer (`ADR-060`)
- `data/` as the only code touching `pg` (`ADR-060`)
- Config/secrets read once in `index.ts`, passed down (`APP-010`, `ADR-130`)
- `db_password` sourced via `LoadCredential=`/`$CREDENTIALS_DIRECTORY`, never hardcoded (`SEC-010.3`)
- The `dist/index.js` build output path — renaming the entrypoint breaks `reference/systemd`'s `ExecStart`
- No secret value ever passed to the logger or the HTTP error response (`SEC-010.5`, `OPS-050.3`)

## Related Documents

- Standards: `ENG-050`, `ENG-060`, `ENG-030`, `OPS-050`, `SEC-010`
- Architecture: `APP-010` (the three-layer pattern this realises)
- ADRs: `ADR-060` (three-layer architecture), `ADR-070` (Node/TypeScript/Express), `ADR-090` (PostgreSQL, ORM deferred), `ADR-130` (systemd credentials)
- Current-State: `CS-APP-010` (the real `apps/{api,web,worker}` convergence this workspace layout matches), `CS-INF-020` (the real Node/Postgres versions this targets)
- Runbooks: none yet
- Reference Implementations: `reference/systemd` (the unit this service's build output must match), `reference/nginx` (the edge a real deployment runs behind — not exercised in this round, see Purpose & Scope), `reference/deployment` (how it actually gets deployed — used for real in this round's verification), `reference/security` (credential provisioning — used for real in this round's verification), `reference/monitoring` (health-check pattern and log aggregation)
