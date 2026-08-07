---
status: Draft
verified: null   # required before Approved: "<method>, YYYY-MM-DD" -- see Purpose & Scope for what's already checked vs. what verified actually requires
---

# reference/monitoring — Health Checks & Alerting

## Purpose & Scope

The last piece `OPS-040`/`OPS-050` still needed: real alerting (`OPS-040.2`) and explicit log retention (`OPS-050.5`). Deliberately not a re-implementation of what already exists — `reference/application` already has a working `/healthz` route and a compliant structured logger (`OPS-050.1`–`.3`); `reference/deployment`'s health gate already polls it. This category generalizes the health-check pattern into something copyable across services, and builds the two things nothing has actually built yet: something that detects "down" and tells a person, and an explicit (not default) log-retention policy.

**Already confirmed, but this is not what `verified` requires.** `terraform/monitoring.tf` was validated for real: merged into a scratch copy of `reference/terraform`'s directory (the way it's actually meant to be used — see Usage), `terraform fmt`/`init`/`validate` all pass against the real, installed `digitalocean` provider (2.99.1) — `digitalocean_uptime_check`, `digitalocean_uptime_alert`, and `digitalocean_monitor_alert` are real resources with the attributes used here, not a guess at the provider's shape. `http/health-router.ts` was actually run — a real Express server driven with real HTTP requests confirmed `GET /healthz` → `200`, `GET /readyz` with a passing check → `200`, and `GET /readyz` with a failing check → `503` with the failure named in the response body. What `verified` still requires: a real `terraform apply` creating a real (billable) uptime check against the live droplet, and the journald config actually installed and confirmed with `journalctl` — deferred, same pattern as every other category here.

Explicitly not covered here:

- **The health-check *content*** — `reference/application`'s `/healthz` route already satisfies `OPS-040.1` for that specific service; `http/health-router.ts` is the generalized pattern other services copy, not a second, competing implementation
- **Log format and content** — `OPS-050.1`–`.3`, already satisfied by `reference/application`'s `logger.ts`; not redefined here
- **Incident response procedure** — `OPS-040`'s own Scope excludes this; a runbook is Deliverable 7
- **`OPS-050.6` (central log aggregation), left an open gap, not fabricated.** No ADR has selected a log-aggregation product. Inventing one here (an ELK stack, Loki, a specific SaaS) would misrepresent an undecided architecture choice as settled — the same discipline `ADR-090` used for the still-open database backup gap. This stays flagged in Compliance as unmet, pending a future ADR.
- **`OPS-040.4` (alert paired with a runbook)** — no runbooks exist yet (Deliverable 7); also flagged as unmet, not faked.

## Contents

| File | Role |
|---|---|
| `http/health-router.ts` | Copyable Express router: `/healthz` (liveness, `OPS-040.1`) and `/readyz` (optional dependency checks) |
| `terraform/monitoring.tf` | `digitalocean_uptime_check` + `digitalocean_uptime_alert` (down, ssl_expiry) + a `digitalocean_monitor_alert` example — a drop-in addition to `reference/terraform`, not a separate Terraform root |
| `journald/journald-socx.conf` | `/etc/systemd/journald.conf.d/` drop-in — explicit retention (`OPS-050.5`) |

## Design Decisions

- **Liveness and readiness are deliberately separate routes.** `/healthz` never depends on a downstream system — if the process is up, it answers `200`, full stop. Conflating liveness with a database check turns a database blip into a process restart loop that can't fix a database outage, a well-documented anti-pattern this router avoids by construction. `/readyz` is where dependency checks belong, and is optional — a service with nothing to check behaves identically to `/healthz`.
- **Built on DigitalOcean's own Uptime Checks / Alert Policies, not a new monitoring stack.** The platform already adopted DigitalOcean (`ADR-160`); its built-in monitoring product satisfies `OPS-040.2` with zero new infrastructure and no new architectural decision to make.
- **`monitoring.tf` is a same-directory addition to `reference/terraform`, not an independent root.** It reuses `reference/terraform`'s existing `digitalocean` provider block, `digitalocean_droplet.app` resource, and `apex_domain`/`app_subdomains` variables rather than redeclaring any of them — reuse also means it's real evidence this Terraform validates as a whole, not just in isolation.
- **Its one new variable (`alert_email`) is declared inside `monitoring.tf` itself, not a second `variables.tf`.** `reference/terraform` already owns that filename; a second file with the same name would silently overwrite the original on copy — caught by the IDE's live diagnostics during authoring (a "no declaration found" error the first draft produced), fixed before this was ever proposed for real use.
- **Uptime checks target the public HTTPS hostname, never the droplet's IP.** Consistent with `ADR-050` — no application is directly internet-facing; monitoring measures what a real user actually reaches, through `reference/nginx`'s edge.
- **An `ssl_expiry` alert is included alongside the `down` alert.** `reference/nginx` already runs real Let's Encrypt certificates with a real renewal cadence; catching an expiring cert before it becomes an outage is a natural, cheap pairing, not scope creep.
- **The `digitalocean_monitor_alert` memory example is illustrative, not required by `OPS-040`.** Included because the real droplet's ~956 MiB RAM (`CS-INF-020`) is a known, already-observed constraint, not a hypothetical one worth demonstrating against.
- **Some `digitalocean_uptime_alert` field semantics are inferred, not confirmed.** The Terraform schema confirms `threshold`/`comparison`/`period` exist as attributes, but not their exact applicability per `type` (`down` vs `ssl_expiry`) — that's DigitalOcean API-documentation-level detail the schema alone doesn't carry. Flagged for confirmation before a real `apply`, the same honesty `reference/terraform` applied to `droplet_size`.

## Compliance

| Requirement | Satisfied by |
|---|---|
| OPS-040.1 | `health-router.ts`'s `/healthz` |
| OPS-040.2 | `monitoring.tf`'s `digitalocean_uptime_alert.app_down` — down detection routed to `var.alert_email` |
| OPS-050.5 | `journald-socx.conf` — explicit `SystemMaxUse`/`MaxRetentionSec`, not left at the OS default |

**Not satisfied by this artefact:** `OPS-050.6` (central log aggregation — no product decided; see Purpose & Scope) and `OPS-040.4` (alert-to-runbook pairing — no runbooks exist yet, Deliverable 7).

## Prerequisites

- `reference/terraform` already adopted (or at minimum, its `main.tf`/`variables.tf` present in the same directory) — `monitoring.tf` depends directly on `digitalocean_droplet.app`, `var.apex_domain`, `var.app_subdomains`
- `reference/nginx` and its real certificates already serving the target hostnames — an uptime check against a host with no working TLS will simply always alert
- A real DigitalOcean API token (same one `reference/terraform` already requires) and a real `alert_email`

## Usage

Parameters: `{{ALERT_EMAIL}}` (via `var.alert_email` in the consuming `.tfvars`, not the file itself — DigitalOcean uptime alerting has no dedicated secret store integration, so this is a plain, non-secret value), `{{JOURNAL...}}` values are pre-filled with reasonable defaults (see `journald-socx.conf`), not left as placeholders.

1. **Health router:** copy `http/health-router.ts` into a consuming service's `src/interface/http/` (see `reference/application`'s layout); wire it in place of, or alongside, an ad hoc `/healthz` route.
2. **Terraform:** copy `terraform/monitoring.tf` into the same directory as `reference/terraform`'s files. Add `alert_email = "{{ALERT_EMAIL}}"` to the relevant `environments/*.tfvars`. `terraform plan` — review before `apply`, same discipline as `reference/terraform`.
3. **journald:** copy `journald/journald-socx.conf` to `/etc/systemd/journald.conf.d/socx.conf` on the host, then `systemctl restart systemd-journald`.
4. Re-verify after adapting, and before `Approved`: a real `terraform apply` against the live droplet (confirm the uptime check appears in the DigitalOcean control panel and a deliberately-broken health check actually triggers the email alert), and confirm `journalctl` respects the new retention on the real host. Record the method and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- `regions` in `digitalocean_uptime_check` — the two included are a reasonable geographic spread, not an account-specific requirement
- `readinessChecks` passed into `health-router.ts` — per what a given service actually depends on
- `SystemMaxUse`/`MaxRetentionSec` — per the target host's actual disk budget

**Must remain unchanged to preserve compliance:**

- `/healthz` never checking a downstream dependency (liveness/readiness separation)
- Uptime checks targeting the public hostname, not the droplet IP (`ADR-050`)
- `alert_email` sourced from a variable, never hardcoded into a `.tf` file

## Related Documents

- Standards: `OPS-040`, `OPS-050`
- Architecture: none directly — this realises operational process, not a target design
- ADRs: `ADR-040` (direct-execution runtime — no orchestrator to hand liveness probing to), `ADR-160` (Terraform), `ADR-050` (edge-only exposure)
- Current-State: `CS-INF-020` (the real droplet constraints — memory, DNS — this is grounded in)
- Runbooks: none yet — alert response procedure is a Deliverable 7 candidate, and is what `OPS-040.4` will eventually require pairing with each alert
- Reference Implementations: `reference/application` (the health-check content this generalizes), `reference/terraform` (the configuration this is a drop-in addition to), `reference/nginx` (the edge every uptime check target passes through), `reference/deployment` (the health gate that already polls `/healthz` during a deploy)
