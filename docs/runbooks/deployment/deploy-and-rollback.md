---
status: Approved
verified: "Real on-host execution, prod-lab-01, 2026-08-07, as part of reference/deployment's verification round: a real v1.0.0 canary deploy (health gate passed against real HTTP traffic), a deliberately broken build proving automatic rollback, a working v1.2.0 followed by an explicit rollback.sh invocation. Every command below is transcribed from that real session, not paraphrased."
---

# deployment/deploy-and-rollback.md — Shipping a Version, and Undoing a Bad One

## Purpose & Scope

The human procedure around `reference/deployment`'s scripts: when to deploy, how to read a deploy's outcome, and the two different ways a rollback happens (automatic, and manual). Does not cover the scripts' own internals — that's `reference/deployment`'s manifest; this is what to actually do at the keyboard.

## Trigger

- **Deploy:** a new version is ready to ship (normally: a push to `main` through `reference/github`'s CI, which hands off to `deployment/deploy-job.yml`; manually, when working outside CI).
- **Rollback:** a deployed version is confirmed bad *after* it already passed its own health gate — a problem that only shows up under real traffic, not the immediate-failure case `deploy-release.sh` already handles on its own.

## Prerequisites

- SSH access as `deploy` (the real, already-provisioned account — `CS-INF-020`)
- `reference/deployment`'s scripts already installed at `{{DEPLOY_DIR}}/scripts/` on the target host
- A built release tarball (see `reference/deployment/workflows/deploy-job.yml` for exactly what goes in it)

## Procedure

### Deploying

1. Build and package the release (CI does this automatically; manually, follow `deploy-job.yml`'s Install → Build → Prune → Package steps in that exact order — installing with `--omit=dev` *before* building will silently break the build, since the build step needs `typescript`, a devDependency).

2. Transfer the tarball and run the real deploy command **as root, via `sudo`, running the whole script** — not as `deploy` with the script's internal `sudo systemctl restart` relied on alone:
   ```
   scp release.tar.gz deploy@<host>:/tmp/release-<version>.tar.gz
   ssh deploy@<host> "sudo /opt/deploy/scripts/deploy-release.sh <app> <version> /tmp/release-<version>.tar.gz"
   ```

3. **If you're overriding `SERVICES` or `HEALTH_URL` via the environment, use `sudo env VAR=val ...`, not `sudo VAR=val ...`.** Found the hard way during this platform's own verification: on this host, `sudo VAR=val cmd` happens to pass the variable through, but that's not guaranteed across systems and sudoers configurations — `sudo env VAR=val cmd` is the form that reliably works everywhere. Getting this wrong doesn't error; it just silently makes the script use its defaults, which can mask what you think you configured.

4. Read the script's own output — it tells you what happened:
   - `Deploy succeeded: <app> <version> is live.` — health gate passed, done.
   - `Health gate FAILED ... Rolling back to ... Rollback succeeded` — the new version never went live; automatic rollback already happened. Investigate the failed release before retrying (see step 6).

### Rolling back a version that already passed its health gate

5. List what's actually on the host if you're not sure of the exact version string to target (version strings, especially untagged `0.0.0-<sha>` ones, don't sort reliably — don't guess):
   ```
   ssh deploy@<host> 'ls /opt/<app>/releases/'
   ```
   Then:
   ```
   ssh deploy@<host> "sudo /opt/deploy/scripts/rollback.sh <app> <target-version>"
   ```
   This never auto-detects "the previous one" — you always name the target explicitly.

### Investigating a failed release

6. A failed release's directory is never deleted — it's left at `/opt/<app>/releases/<failed-version>/` for exactly this:
   ```
   ssh deploy@<host> 'sudo journalctl -u <app>-api.service -n 100 --no-pager'
   ```
   Common real causes found during this platform's own verification: a genuinely broken build (crashes on start — the health gate is supposed to catch this, and did); a missing `Environment=` variable the app needs but the systemd unit never declared (see `incident-response/app-down-alert.md` step 4); a database permission the new code path needs but was never granted.

## Verification

- `curl -s -w '%{http_code}\n' https://<app>.socx.org.uk/healthz` (or directly against `127.0.0.1:<port>` on the host, bypassing the edge, to isolate where a problem is) returns `< 500`.
- `ssh deploy@<host> 'sudo readlink -f /opt/<app>/current'` points at the version you expect.
- For a rollback specifically: confirm real user-facing behaviour, not just the health check — a health-gate pass only proves the process is up, not that the specific bad behaviour you rolled back to fix is actually gone.

## Escalation / Rollback

If `rollback.sh` itself fails its own health gate against the target version, **it does not cascade to an even older version automatically** — that's a deliberate design choice (an older release isn't automatically assumed safe). At that point: manual investigation is required — check `journalctl` for the target version's own history, or consider whether the actual fix needs a forward deploy (a new, corrected version) rather than a rollback at all.

## Related Documents

- Standards: `OPS-030` (`OPS-030.1`–`.3`)
- Reference Implementations: `reference/deployment` (the scripts this operates), `reference/systemd` (the unit layout `deploy-release.sh` flips), `reference/github` (the CI job that normally triggers this)
- Runbooks: `incident-response/app-down-alert.md` (diagnosing *why* before deciding to roll back), `maintenance/credential-rotation.md` (if the failure traces to a stale credential)
