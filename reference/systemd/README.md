---
status: Draft
verified: null
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

## Compliance

| Requirement | Satisfied by |
|---|---|
| SEC-010.3 | `app-api.service`, `app-worker.service` — `LoadCredential=` sources secrets from systemd credentials, never hardcoded |
| OPS-010.2 | `app-api.service`, `app-worker.service` — `Environment=SOCX_ENV=` makes the environment tier identifiable at runtime |
| OPS-030.2 | `app-api.service` — `current → releases/{{VERSION}}` layout keeps the running version pinned and traceable |
| OPS-060.1 | `db-backup@.service` + `db-backup-*.timer` — automated, scheduled database backups |

## Usage

Parameters: `{{APP_NAME}}`, `{{APP_USER}}`, `{{APP_DIR}}`, `{{APP_PORT}}`, `{{NODE_BIN}}` (absolute path, e.g. `/usr/bin/node`), `{{ENVIRONMENT}}` (per `OPS-010` tier), `{{CREDENTIALS_DIR}}`, `{{BACKUP_USER}}`, `{{DEPLOY_DIR}}`, `{{DB_NAME}}`.

1. Copy the unit into the consuming repository (`platform-infra/systemd/`), substituting all placeholders — grep for `{{` to confirm none remain.
2. Install to `/etc/systemd/system/`, then `systemctl daemon-reload`.
3. Services: `systemctl enable --now {{APP_NAME}}-api.service`. Backup timers, per database: `systemctl enable --now db-backup-daily@{{DB_NAME}}.timer`.
4. Re-verify after adapting: `systemd-analyze verify` on each unit, confirm the service survives `systemctl restart` with `systemctl status`, and confirm a timer fires with `systemctl list-timers`.

Adjust `LoadCredential=` lines and `ReadWritePaths=` to what the application actually needs — both are deliberately minimal here.

## Related Documents

- Standards: `SEC-010`, `OPS-010`, `OPS-030`, `OPS-040`, `OPS-060`
- Architecture: `INF-010` (systemd-managed processes behind the shared edge), `APP-010` (config read once at startup)
- ADRs: `ADR-040` (direct-execution runtime), `ADR-130` (systemd credentials)
- Current-State: `CS-INF-010` (the `nvm` fragility and empty scaffolds this replaces)
- Runbooks: none yet — restart/rollback and restore procedures are Deliverable 7
- Automation: backup script pattern pending in `reference/deployment` (Deliverable 6.7)
