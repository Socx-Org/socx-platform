---
status: Draft
verified: null   # required before Approved: "<OS>, systemd <version>, <method>, YYYY-MM-DD"
---

# reference/systemd — Service & Timer Units

## Purpose & Scope

Canonical systemd units for running SOCX applications as **direct-execution** processes (ADR-040): the node binary is invoked directly, with no shell wrapper, no `bash -lc`, and no `nvm` — eliminating the login-shell startup fragility recorded in `CS-INF-010`. Also provides the templated backup job and its schedules (`OPS-060.1`), replacing the empty scaffolds found in `platform-infra`.

Explicitly not covered here:

- **Backup script content and off-host storage** (`OPS-060.2`) — deployment tooling; canonical pattern belongs to `reference/deployment`
- **Restore procedure, RPO/RTO, and incident response** — runbook content (`OPS-060.4`, `OPS-060.5`, Deliverable 7)
- **How credentials get onto the host** — `reference/security`
- **Log format and content** — application-side, governed by `OPS-050`

## Contents

| File | Role |
|---|---|
| `app-api.service` | Direct-execution unit for an application API process (credentials, hardening, versioned-release layout) |
| `app-worker.service` | Same pattern for an application worker process |
| `db-backup@.service` | Templated one-shot backup job; instance `%i` is the database name |
| `db-backup-daily@.timer` | Daily schedule for `db-backup@%i`, persistent across downtime |
| `db-backup-hourly@.timer` | Hourly schedule, for databases whose RPO requires it |

## Design Decisions

Key choices embodied by these units — each links to its decision record rather than re-arguing it:

- **Direct execution, absolute paths** — `ExecStart` invokes the runtime binary directly (`{{NODE_BIN}}`, absolute); no login shell, no `nvm`. Per `ADR-040`; removes the startup-fragility class documented in `CS-INF-010`.
- **Secrets via systemd credentials** — `LoadCredential=`, never `Environment=` or `EnvironmentFile=` for anything secret. Per `ADR-130`; keeps secrets out of the process environment, where they leak into logs and debug output (`SEC-010.5`).
- **Versioned releases behind a `current` symlink** — pins the running version to an exact release (`OPS-030.2`) and makes rollback a symlink flip + restart rather than a redeploy (`OPS-030.3`), with the flip mechanics owned by `reference/deployment`.
- **Hardening on by default** — `NoNewPrivileges`, `ProtectSystem=strict`, `ProtectHome`, `PrivateTmp`; per the *secure by default* architecture principle (`docs/architecture/README.md`), the secure configuration is the starting point and loosening requires justification.
- **journald as the log sink** — units only route stdout/stderr; log format and content are application-side, governed by `OPS-050`.
- **Templated backup instances (`%i`)** — one unit serves every database; `Persistent=true` recovers missed runs at boot instead of silently skipping them (`OPS-060.1`).

## Compliance

| Requirement | Satisfied by |
|---|---|
| SEC-010.3 | `app-api.service`, `app-worker.service` — `LoadCredential=` sources secrets from systemd credentials, never hardcoded |
| OPS-010.2 | `app-api.service`, `app-worker.service` — `Environment=SOCX_ENV=` makes the environment tier identifiable at runtime |
| OPS-030.2 | `app-api.service` — `current → releases/{{VERSION}}` layout keeps the running version pinned and traceable |
| OPS-060.1 | `db-backup@.service` + `db-backup-*.timer` — automated, scheduled database backups |

## Prerequisites

Assumptions that must hold before adopting these units:

- **OS / systemd** — Linux with systemd ≥ 245 (`LoadCredential=` support); the platform target is a current Ubuntu LTS release (currently Ubuntu 26.04 LTS, per `CS-INF-020`), per `ADR-040` and `CS-TEC-010`. Exact systemd version to be confirmed at Bootstrap Phase B0.
- **Runtime** — Node.js (current LTS line, per `ADR-070`) installed system-wide at a fixed absolute path (`{{NODE_BIN}}`), not per-user via a version manager.
- **Application user** — a dedicated non-root system user per application (`{{APP_USER}}`), per `SEC-030` least privilege.
- **Deployment layout** — `{{APP_DIR}}/releases/<version>` with a `current` symlink and a `{{APP_DIR}}/shared` directory, created by deploy tooling (`reference/deployment`).
- **Build artefacts** — the application is built in CI (`ENG-040`), so `current/apps/api/dist/index.js` exists on the host; nothing is built on the host itself.
- **Credentials** — secret files provisioned on the host under `{{CREDENTIALS_DIR}}`, root-readable only (provisioning pattern: `reference/security`).
- **Datastores** — `postgresql.service` (and `redis-server.service` where used) present, for `After=` ordering.
- **Backup script** — `{{DEPLOY_DIR}}/scripts/backup-db.sh` present before enabling the backup timers (`reference/deployment`).

## Usage

Parameters: `{{APP_NAME}}`, `{{APP_USER}}`, `{{APP_DIR}}`, `{{APP_PORT}}`, `{{NODE_BIN}}` (absolute path, e.g. `/usr/bin/node`), `{{ENVIRONMENT}}` (per `OPS-010` tier), `{{CREDENTIALS_DIR}}`, `{{BACKUP_USER}}`, `{{DEPLOY_DIR}}`, `{{DB_NAME}}`.

1. Copy the unit into the consuming repository (`platform-infra/systemd/`), substituting all placeholders — grep for `{{` to confirm none remain.
2. Install to `/etc/systemd/system/`, then `systemctl daemon-reload`.
3. Services: `systemctl enable --now {{APP_NAME}}-api.service`. Backup timers, per database: `systemctl enable --now db-backup-daily@{{DB_NAME}}.timer`.
4. Re-verify after adapting: `systemd-analyze verify` on each unit, confirm the service survives `systemctl restart` with `systemctl status`, and confirm a timer fires with `systemctl list-timers`. Record the OS, systemd version, method, and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- All `{{PLACEHOLDER}}` values
- `LoadCredential=` lines — add or remove to match the application's actual secrets
- `After=`/`Wants=` datastore dependencies — only what the application really requires
- `ReadWritePaths=` — only paths the application legitimately owns
- Timer cadence (daily vs hourly) — per the project's RPO (`OPS-060.4`)

**Must remain unchanged to preserve compliance:**

- Direct `ExecStart` of the runtime binary — reintroducing a shell wrapper, login shell, or version manager is a regression to the failure mode `ADR-040` removed
- Secrets delivered via `LoadCredential=` — moving a secret into `Environment=` or `EnvironmentFile=` breaks `SEC-010.3`
- `WorkingDirectory` on the `current` symlink and the versioned-release layout (`OPS-030.2`)
- `Environment=SOCX_ENV=` present (`OPS-010.2`)
- The hardening block and `journald` output — loosening beyond `ReadWritePaths=` needs a recorded exception (`GEN-010.9`); a permanent deviation is an ADR (`DOC-020.2`)

## Related Documents

- Standards: `SEC-010`, `OPS-010`, `OPS-030`, `OPS-040`, `OPS-060`
- Architecture: `INF-010` (systemd-managed processes behind the shared edge), `APP-010` (config read once at startup)
- ADRs: `ADR-040` (direct-execution runtime), `ADR-130` (systemd credentials)
- Current-State: `CS-INF-010` (the `nvm` fragility and empty scaffolds this replaces)
- Runbooks: none yet — restart/rollback and restore procedures are Deliverable 7
- Automation: backup script pattern pending in `reference/deployment` (Deliverable 6.7)
