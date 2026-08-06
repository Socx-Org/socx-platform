---
status: Draft
verified: null   # required before Approved: "<method>, YYYY-MM-DD" -- see Purpose & Scope for what this round is deliberately not
---

# reference/deployment — Deploy & Rollback Glue

## Purpose & Scope

The mechanism connecting CI → droplet → `reference/systemd`'s versioned-release layout: how a built artefact actually gets onto the host, becomes the running version, and comes back off again if it's bad (`ADR-040`, `ADR-150`, `OPS-030`). This is the piece `reference/systemd`'s `current` symlink and `reference/github`'s deploy-job stub both pointed at but deliberately deferred.

**What this is not.** This provides the deploy *mechanism* only. It does not resolve `reference/nginx`'s remaining `502`s on `rms`/`ams`/`www` — those need real application code behind them, which is `reference/application` (Deliverable 6.8), not yet built. Deploying nothing still deploys nothing, correctly.

Explicitly not covered here:

- **The application itself** (build output, `dist/` layout beyond what the release tarball assumes) — `reference/application`
- **How credentials reach the droplet or CI** — `reference/security` (systemd credentials), and the named `${{ secrets.* }}` in `deploy-job.yml` (CI provider's own store, `SEC-010.6`)
- **Branch protection / CI gating itself** — `reference/github`; this only supplies the `deploy` job's real steps, not the `ci` job or the protection rules around merging
- **Health endpoint implementation** — `reference/monitoring` (Deliverable 6.9); the health gate here has a working default (any HTTP response below 500) precisely because no SOCX app has a confirmed dedicated endpoint yet (`OPS-040.1`)
- **Restore procedure, RPO/RTO** — runbook content (`OPS-060.4`, `OPS-060.5`, Deliverable 7); `backup-db.sh` is the mechanism, not the procedure around it

**On `verified` for this round.** As with every other reference implementation here, authoring and on-host verification are separate, deliberately sequenced rounds. This round is authoring only: the scripts have been reviewed for shell correctness (`set -euo pipefail`, atomic symlink flips, no unquoted expansions of user-controlled values) but not yet run against the real droplet. A later round deploys a versioned canary, proves rollback by deploying a second version and rolling back, and proves `backup-db.sh` against a real database — the same pattern `reference/systemd`/`reference/nginx` already went through. `status` stays `Draft` and `verified` stays `null` until that happens.

## Contents

| File | Role |
|---|---|
| `scripts/deploy-release.sh` | Extracts a versioned release, flips the `current` symlink, restarts services, health-gates the restart, automatically rolls back on failure |
| `scripts/rollback.sh` | Rolls back to an explicit, already-deployed version — for a problem found after a deploy already succeeded |
| `scripts/backup-db.sh` | Database backup + off-host copy + local retention, invoked by `reference/systemd`'s `db-backup@.service` |
| `workflows/deploy-job.yml` | Real steps for `reference/github`'s `ci.yml` deploy-job stub |

## Design Decisions

- **One release directory, multiple services.** An app's API and worker units (`reference/systemd`) share the same `{{APP_DIR}}/current` symlink and monorepo build output — `deploy-release.sh` extracts and flips once, then restarts whichever `SERVICES` are named, rather than treating each unit as an independent deploy.
- **The health gate has a real default without requiring a real health endpoint.** No SOCX app has a confirmed `/health` route yet (`OPS-040.1` unimplemented anywhere). The default gate is `systemctl is-active`; if `HEALTH_URL` is set, any HTTP status below 500 (including 404) additionally counts as alive — proof the process is up and serving, not proof a specific route exists. This is upgradable once `reference/monitoring` lands, not blocked waiting for it.
- **`rollback.sh` never auto-detects "the previous version."** Version strings — especially the `0.0.0-<sha>` form used for untagged deploys — don't sort reliably. A human (or a runbook) names the target explicitly. `deploy-release.sh`'s *own* automatic rollback is a different, narrower case: it only ever returns to the one release that was live immediately before, recorded before touching anything.
- **A failed release is never deleted, only abandoned.** Both scripts leave a failed release's directory on disk for inspection — disk space is cheap, evidence of what specifically broke is not.
- **Version string satisfies `OPS-030.1` and `.2` at once.** `deploy-job.yml` computes the real git tag when deploying from one (SemVer), otherwise `0.0.0-<short-sha>` (still valid SemVer, still traceable to an exact commit) — an ordinary push to `main` doesn't need a formal release tag to comply.
- **`deploy-job.yml` uses plain OpenSSH, not a marketplace deploy action.** Fewer third-party actions to trust and pin; the remote side is already reduced to one tested command, so there is no choreography a dedicated action would meaningfully simplify.
- **Grounded in `rms`'s real `deploy.yml` (SSH-transfer of a built artefact), with its remote choreography replaced.** The useful idea kept: bundling production `node_modules` into the release tarball so the host needs no npm-registry access at deploy time. Dropped entirely: `nvm`, raw `systemctl` calls scattered through the workflow — exactly the fragility `ADR-040`/`CS-INF-010` retired, now collapsed into the one `deploy-release.sh` invocation.
- **`backup-db.sh` refuses to claim compliance it hasn't earned.** If `OFFHOST_TARGET` is unset, it says so on stderr rather than silently leaving `OPS-060.2` unmet.

## Compliance

| Requirement | Satisfied by |
|---|---|
| OPS-030.1 | `deploy-job.yml`'s version computation — always valid SemVer |
| OPS-030.2 | `deploy-job.yml`'s version computation — always traceable to an exact commit or tag |
| OPS-030.3 | `deploy-release.sh` / `rollback.sh` — rollback is a symlink flip + restart, not a full redeploy |
| OPS-030.5 | `deploy-job.yml`'s `needs: [ci]` + `environment:` (a GitHub Environment can require approval) |
| OPS-060.1 | `backup-db.sh`, invoked by `reference/systemd`'s timers |
| OPS-060.2 | `backup-db.sh`'s `OFFHOST_TARGET` rsync step — when configured; the script itself flags the gap when it isn't |

**Not satisfied by this artefact:** `OPS-030.4` (rollback exercised at least once per review cycle) is a recurring practice, not something a script can demonstrate by existing — it belongs to a runbook and a review cadence (Deliverable 7).

## Prerequisites

- `reference/systemd`'s versioned-release layout already in place on the host: `{{APP_DIR}}/releases/`, `{{APP_DIR}}/shared/`, and (after a first deploy) `{{APP_DIR}}/current`
- The scripts themselves installed on the host at `{{DEPLOY_DIR}}/scripts/` (referenced by both `reference/systemd`'s backup units and `deploy-job.yml`)
- The `deploy` system account — real and already provisioned (`CS-INF-020`): passwordless `sudo`, used both for the SSH deploy step and for `db-backup@.service`'s `{{BACKUP_USER}}` if the same account is reused
- `DROPLET_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY` configured as CI-provider secrets (`SEC-010.6`) — these name the already-real `deploy` account, not a new identity
- For `backup-db.sh`: non-interactive Postgres access for `{{BACKUP_USER}}` already configured (`.pgpass` or peer auth), and `{{BACKUP_DIR}}` created with correct ownership

## Usage

Parameters: `{{APP_NAME}}`, `{{APP_DIR}}`, `{{DEPLOY_DIR}}`, `{{ENVIRONMENT}}`, `{{BACKUP_USER}}`, `{{OFFHOST_HOST}}`.

1. Copy `scripts/*.sh` into the consuming repository (or directly onto the host under `{{DEPLOY_DIR}}/scripts/`), `chmod +x` each.
2. Copy `workflows/deploy-job.yml`'s content over `reference/github`'s `ci.yml` `deploy:` stub job, substituting `{{ENVIRONMENT}}`, `{{DEPLOY_DIR}}`, `{{APP_NAME}}`.
3. Configure `DROPLET_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY` as CI-provider secrets.
4. On the host, ensure `{{APP_DIR}}/releases/` and `{{APP_DIR}}/shared/` exist (per `reference/systemd`'s Prerequisites) before the first deploy.
5. To enable backups: create `{{BACKUP_DIR}}`, configure `{{BACKUP_USER}}`'s Postgres access, set `OFFHOST_TARGET` in the unit's environment, then enable `reference/systemd`'s timer per database.
6. Re-verify after adapting: deploy a real versioned canary, confirm the health gate and automatic rollback both actually trigger (deliberately fail a canary build to test this), deploy a second version and use `rollback.sh` to return to the first, and run `backup-db.sh` against a real database. Record the method and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- `SERVICES` per app (which units a deploy actually restarts)
- `HEALTH_URL` once `reference/monitoring` provides a real health endpoint
- `BACKUP_RETENTION_DAYS`, `OFFHOST_TARGET` per the project's actual RPO/storage target
- The tarball contents in `deploy-job.yml`'s "Package release" step, if a project's build output layout differs from `apps/*/dist`

**Must remain unchanged to preserve compliance:**

- The atomic symlink-flip pattern (`ln -sfn` into a temp name, then `mv -Tf`) — a direct `ln -sfn` onto the live `current` path is not atomic and can be observed mid-flip
- `rollback.sh`'s explicit-target-only argument — adding "roll back to previous" auto-detection reintroduces the unreliable-sort problem this script exists to avoid
- Failed releases are never auto-deleted
- Secrets sourced only via `${{ secrets.* }}` in `deploy-job.yml`, never hardcoded (`SEC-010.1`, `ENG-040.6`)

## Related Documents

- Standards: `OPS-030`, `OPS-060`, `SEC-010`
- Architecture: `INF-010` (systemd-managed processes this deploys into)
- ADRs: `ADR-040` (direct-execution runtime — no orchestration to hand deploys off to), `ADR-150` (GitHub Actions)
- Current-State: `CS-INF-020` (the real `deploy` account this reuses), `CS-TEC-010` (the real `rms` deploy workflow this was grounded in and corrected against)
- Runbooks: none yet — the on-host verification round, restore procedure, and rollback-cadence practice (`OPS-030.4`) are Deliverable 7 candidates
- Reference Implementations: `reference/systemd` (the layout and units this deploys into), `reference/github` (the CI job this fills in), `reference/security` (credential pattern for Postgres/SSH access)
