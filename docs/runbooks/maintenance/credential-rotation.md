---
status: Approved
verified: "Real on-host execution, prod-lab-01, 2026-08-07, as part of reference/security's verification round: a real db_password credential written via set-credential.sh, the empty-input refusal confirmed, permissions confirmed (600 root:root), confirmed the value never appears in journalctl or shell history, confirmed a real running service picked up the new value via LoadCredential= after a restart."
---

# maintenance/credential-rotation.md — Rotating a systemd Credential

## Purpose & Scope

Provisioning or rotating a credential that a service consumes via `LoadCredential=` (`reference/systemd`, `ADR-130`) — a database password, a JWT signing secret, a service-to-service credential. The mechanism is identical for a first-time write and a rotation; there's no separate "rotate mode."

**Not covered here:** operator-held API tokens (a DigitalOcean or Cloudflare API token used from your own machine to run `reference/terraform`) — those aren't systemd credentials, aren't written to the droplet at all, and are rotated in the provider's own dashboard (revoke, generate new, update wherever you source `TF_VAR_do_token`/`TF_VAR_cloudflare_api_token` from — an environment variable or your own secret manager, never a committed file). If you've ever pasted one of those into a chat session or any other channel that retains history, rotate it regardless of whether anything actually went wrong — `SEC-010.4`'s "known or suspected exposure" bar is deliberately low.

## Trigger

- **Scheduled/routine rotation** (per your own security posture — no fixed interval is mandated by any current standard).
- **Suspected or confirmed exposure** (`SEC-010.4`) — rotate immediately, don't wait to confirm real misuse first.
- **Provisioning a credential for the first time**, e.g. as part of deploying a new service.

## Prerequisites

- Root or `sudo` access on the target host
- The new secret value, generated appropriately for its purpose (e.g. `openssl rand -base64 32` for a random secret; a real database password if rotating DB access — which also requires changing it at the database itself, see step 3)
- `reference/security`'s `scripts/set-credential.sh` present on the host (same `{{DEPLOY_DIR}}/scripts/` location `reference/deployment`'s tooling lives in)

## Procedure

1. **Generate or obtain the new value** — never type it directly into a command where it could land in shell history. Piping avoids this:
   ```
   openssl rand -base64 32 | sudo /opt/deploy/scripts/set-credential.sh <app-name> <credential-name>
   ```
   or, for a value you already have (e.g. a new database password):
   ```
   printf '%s' "$NEW_VALUE" | sudo /opt/deploy/scripts/set-credential.sh <app-name> <credential-name>
   ```
   The script refuses an empty value outright (confirmed for real: piping nothing produces `ERROR: no data received on stdin -- refusing to write an empty credential.` and writes nothing) — a safety net against an accidentally-empty pipe overwriting a working credential with nothing.

2. **If rotating a credential the value needs to match elsewhere** (most commonly: a database password), change it at the source *before* or *immediately after* writing the file — the two must agree, or the next restart will fail authentication. For a Postgres role:
   ```
   sudo -u postgres psql -c "ALTER ROLE <role> WITH PASSWORD '<new-value>';"
   ```

3. **Restart the consuming service** so it re-reads the credential via `LoadCredential=` — a credential file write alone does nothing until the service restarts:
   ```
   sudo systemctl restart <app>-api.service
   ```

4. **Confirm nothing was logged.** The write itself never should be, but it's cheap to check:
   ```
   sudo journalctl --since "5 minutes ago" | grep -i <credential-name>
   ```
   Real result from this platform's own verification: only the `sudo` command-invocation audit line appears (`COMMAND=/opt/deploy/scripts/set-credential.sh <app> <credential-name>`) — never the value itself.

## Verification

- File permissions: `sudo stat -c "%a %U:%G" /etc/credentials/<app>/<credential-name>` → `600 root:root`.
- The consuming service is active post-restart: `sudo systemctl is-active <app>-api.service`.
- The service actually functions with the new credential — e.g. for a database password, confirm the app can actually query the database (`incident-response/app-down-alert.md`'s procedure covers what a wrong credential looks like from the outside: a clean, specific auth error in `journalctl`, not a silent hang).

## Escalation / Rollback

If the service fails to start after rotation, the credential file and the actual value at the source (e.g. the database role's password) have almost certainly drifted out of sync — re-run step 1 with the exact value step 2 set, don't guess. There is no automatic rollback for a credential; the previous value is gone the moment the atomic rename in step 1 completes (by design — `reference/security`'s Design Decisions explain why).

## Related Documents

- Standards: `SEC-010` (`SEC-010.3`–`.5`)
- Reference Implementations: `reference/security` (the script this operates), `reference/systemd` (the `LoadCredential=` consumption side)
- Runbooks: `incident-response/app-down-alert.md` (what a credential problem looks like from the outside)
