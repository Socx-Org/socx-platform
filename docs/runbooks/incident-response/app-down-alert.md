---
status: Approved
verified: "Diagnostic steps run for real against the live droplet (prod-lab-01), 2026-08-07: public HTTPS checks against all three real down alerts (ghs/rms/ams, all 502), on-host port listener check (nginx only, no app ports bound), nginx status check, systemd app-unit inventory (none installed). Confirms this runbook's diagnostic sequence produces a correct, actionable diagnosis. The full incident lifecycle (alert -> triage -> fix -> resolve) has not been exercised against a genuine unexpected regression, since the current down state is the known, expected one -- see Purpose & Scope."
---

# incident-response/app-down-alert.md — Responding to a `reference/monitoring` Down Alert

## Purpose & Scope

What to do when a `digitalocean_uptime_alert` (type `down`) fires for one of the platform's applications. Satisfies `OPS-040.4` — the requirement that every alert be paired with a runbook describing the response — for the alerts `reference/monitoring` creates.

Does not cover: TLS/certificate expiry (a separate `ssl_expiry` alert, different triage — check `reference/nginx`'s certbot renewal first, not this document), droplet-level resource alerts (the `digitalocean_monitor_alert` memory example — that's a capacity/scaling question, not a down-service one), or an actual deploy/rollback (that's `deployment/deploy-and-rollback.md` — this runbook stops at diagnosis and hands off).

## Trigger

An email from DigitalOcean, subject naming one of `ghs-down`, `rms-down`, or `ams-down` (or reference/monitoring the manifest's) alert address (`socx9@yahoo.com` at time of writing). Confirms in the body which check fired and which region(s).

**Known state as of 2026-08-07, don't skip this check:** no application has ever been deployed to the real droplet (`reference/systemd`'s and `reference/nginx`'s canaries were both disposable and torn down after their own verification rounds). `ghs`, `rms`, and `ams` all genuinely return `502` right now — this is the expected, already-documented state (`CS-INF-020`), not an incident. Before doing anything else, check whether the app in question has ever actually been deployed (`CS-INF-020`'s Reference Implementations / Application Scaffolding sections, or just: has `#74`-style real deployment happened for this specific app?). If not, there is nothing to fix — the alert is correctly reporting reality, and this runbook's job is done: no action, no false "resolution."

If the app *was* previously working and this is a genuine regression, continue to Procedure.

## Prerequisites

- SSH access to the droplet (`deploy` account — same key used throughout `reference/deployment`)
- The app name (matches its systemd unit prefix, e.g. `ghs` → `ghs-api.service`)

## Procedure

1. **Confirm it publicly, not just from the alert email** — cross-check from outside the droplet:
   ```
   curl -s -o /dev/null -w '%{http_code}\n' https://<app>.socx.org.uk/healthz
   ```
   A `502` means nginx is up but has nothing to proxy to. A connection failure/timeout instead means the problem is at the edge or DNS, not the app — a different, larger incident; escalate rather than continuing this runbook.

2. **Check nginx itself is healthy** (rules out the edge as the cause of a `502`):
   ```
   ssh deploy@<droplet> 'sudo systemctl is-active nginx'
   ```

3. **Check whether the app's process is actually listening:**
   ```
   ssh deploy@<droplet> 'sudo ss -tlnp | grep :<app-port>'
   ```
   Nothing listed means the process isn't running or never bound to the expected port — proceed to step 4. Something listed on the wrong port is a configuration mismatch between the app and nginx's site config (`reference/nginx`) — check `PORT`/`Environment=PORT=` against the site's `proxy_pass` target.

4. **Check the service's real status and recent logs:**
   ```
   ssh deploy@<droplet> 'sudo systemctl status <app>-api.service --no-pager'
   ssh deploy@<droplet> 'sudo journalctl -u <app>-api.service -n 100 --no-pager'
   ```
   Look for: a crash loop (`Restart=on-failure` cycling — check the exact error in the log, don't guess), a missing/misconfigured `Environment=` variable (`reference/application`'s on-host verification found exactly this: a service crashing with a clean, specific error like `password authentication failed` because a required `DB_HOST`/`DB_NAME`/`DB_USER` was never set in the unit), or a credential problem (`LoadCredential=` pointing at a file that doesn't exist or was rotated without a restart — see `maintenance/credential-rotation.md`).

5. **If the crash correlates with a recent deploy**, this is `deployment/deploy-and-rollback.md`'s territory — hand off there. `deploy-release.sh` should have already auto-rolled-back a failed health gate on its own; if the service is still down, check whether the auto-rollback itself succeeded (`sudo readlink -f /opt/<app>/current` — does it point at the version you expect?).

## Verification

- `curl -s -w '%{http_code}\n' https://<app>.socx.org.uk/healthz` returns `< 500`.
- `ssh deploy@<droplet> 'sudo systemctl is-active <app>-api.service'` returns `active`.
- The DigitalOcean uptime check's real-time state (`GET /v2/uptime/checks/<id>/state`) shows `status: "UP"` for both regions — don't rely on the email stopping as confirmation; check the source of truth directly.

## Escalation / Rollback

Single-operator platform at time of writing — there is no secondary on-call to page. If steps 1–4 don't produce a clear cause within a reasonable diagnostic window, the safe default is `deployment/deploy-and-rollback.md`'s manual rollback to the last known-good version, then diagnose the broken one offline rather than leaving the service down while investigating.

## Related Documents

- Standards: `OPS-040` (`OPS-040.2` real alerting, `OPS-040.4` this pairing)
- Reference Implementations: `reference/monitoring` (the alert this responds to), `reference/deployment` (the rollback this may hand off to), `reference/application` (the real `Environment=` gap this runbook's step 4 is grounded in), `reference/nginx` (the edge a `502` originates from)
- Runbooks: `deployment/deploy-and-rollback.md`, `maintenance/credential-rotation.md`
