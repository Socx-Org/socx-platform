---
status: Approved
verified: "Real terraform apply against the real droplet/DNS: 3 digitalocean_uptime_check + 3 digitalocean_uptime_alert(down) + 3 digitalocean_uptime_alert(ssl_expiry) + 1 digitalocean_monitor_alert, reaching a genuine zero-diff plan. Confirmed live via the DigitalOcean API: all three uptime checks show real DOWN status with alert_count=2 each (ghs/rms/ams genuinely have nothing deployed yet) and real days_to_ssl_expiry=89 -- the alerting pipeline fired for real, not just 'was created'. journald-socx.conf installed for real on the droplet (/etc/systemd/journald.conf.d/socx.conf), confirmed active via systemd-analyze cat-config and a real post-restart log round-trip. health-router.ts run with a real Express server and real HTTP requests. Two real API-contract bugs found and fixed (see Design Decisions): digitalocean_uptime_alert requires 'period', which is absent from the Terraform schema entirely; and unset comparison/threshold silently pick up real API-side defaults that Terraform then perpetually diffs against. 2026-08-07"
---

# reference/monitoring — Health Checks & Alerting

## Purpose & Scope

The last piece `OPS-040`/`OPS-050` still needed: real alerting (`OPS-040.2`) and explicit log retention (`OPS-050.5`). Deliberately not a re-implementation of what already exists — `reference/application` already has a working `/healthz` route and a compliant structured logger (`OPS-050.1`–`.3`); `reference/deployment`'s health gate already polls it. This category generalizes the health-check pattern into something copyable across services, and builds the two things nothing has actually built yet: something that detects "down" and tells a person, and an explicit (not default) log-retention policy.

**What `verified` covers.** Every artefact in this category was exercised against real infrastructure, not just validated in isolation: `monitoring.tf` was actually applied to the real droplet/DNS (not merely `plan`ned), reaching a genuine zero-diff state; the resulting uptime checks are live and have already fired real alerts (`ghs`/`rms`/`ams` genuinely have nothing deployed yet, so `DOWN` is the honest, correct status); `journald-socx.conf` is installed and active on the real host; `health-router.ts` was run with a real Express server and real HTTP requests, covering both its liveness and readiness branches.

Explicitly not covered here:

- **The health-check *content*** — `reference/application`'s `/healthz` route already satisfies `OPS-040.1` for that specific service; `http/health-router.ts` is the generalized pattern other services copy, not a second, competing implementation
- **Log format and content** — `OPS-050.1`–`.3`, already satisfied by `reference/application`'s `logger.ts`; not redefined here
- **Incident response procedure** — `OPS-040`'s own Scope excludes this; the response procedure itself is `docs/runbooks/incident-response/app-down-alert.md` (Deliverable 7), not restated here
- **`OPS-050.6` (central log aggregation), left an open gap, not fabricated.** No ADR has selected a log-aggregation product. Inventing one here (an ELK stack, Loki, a specific SaaS) would misrepresent an undecided architecture choice as settled — the same discipline `ADR-090` used for the still-open database backup gap. This stays flagged in Compliance as unmet, pending a future ADR.

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
- **`period` is set explicitly on every `digitalocean_uptime_alert`, despite not appearing as `required` in Terraform's own schema dump.** A real `apply` failed outright with `missing required field 'period'` — the schema JSON alone said nothing about this; only a real API call surfaced it. `"5m"` on both `down` and `ssl_expiry` alerts.
- **`comparison` and `threshold` are set explicitly on `app_down`, matching the real API's own server-side defaults (`"less_than"`, `1`).** Left unset, the real API silently applies those defaults anyway — but Terraform then sees the *config* as not declaring them and proposes nulling them out on every subsequent `plan`, forever. Declaring the real default explicitly is what actually reaches a stable, zero-diff state. Found by applying, not by reading documentation.

## Compliance

| Requirement | Satisfied by |
|---|---|
| OPS-040.1 | `health-router.ts`'s `/healthz` |
| OPS-040.2 | `monitoring.tf`'s `digitalocean_uptime_alert.app_down` — down detection routed to `var.alert_email` |
| OPS-050.5 | `journald-socx.conf` — explicit `SystemMaxUse`/`MaxRetentionSec`, not left at the OS default |
| OPS-040.4 | `docs/runbooks/incident-response/app-down-alert.md` — a real, Approved runbook paired with the `down` alert |

**Not satisfied by this artefact:** `OPS-050.6` (central log aggregation — no product decided; see Purpose & Scope).

## Prerequisites

- `reference/terraform` already adopted (or at minimum, its `main.tf`/`variables.tf` present in the same directory) — `monitoring.tf` depends directly on `digitalocean_droplet.app`, `var.apex_domain`, `var.app_subdomains`
- `reference/nginx` and its real certificates already serving the target hostnames — an uptime check against a host with no working TLS will simply always alert
- A real DigitalOcean API token (same one `reference/terraform` already requires) and a real `alert_email`

## Usage

Parameters: `{{ALERT_EMAIL}}` — pass as `TF_VAR_alert_email` (an environment variable, like `do_token`/`cloudflare_api_token`) rather than committing it to a `.tfvars` file; it's not a secret, but it's also not something every clone of this repository should carry as a literal default. `{{JOURNAL...}}` values are pre-filled with reasonable defaults (see `journald-socx.conf`), not left as placeholders.

1. **Health router:** copy `http/health-router.ts` into a consuming service's `src/interface/http/` (see `reference/application`'s layout); wire it in place of, or alongside, an ad hoc `/healthz` route.
2. **Terraform:** copy `terraform/monitoring.tf` into the same directory as `reference/terraform`'s files. Set `TF_VAR_alert_email`. `terraform plan` — review before `apply`, same discipline as `reference/terraform`. Expect the first `plan` to show all 10 resources as new; `apply` reaches a real zero-diff state on the next `plan` (verified for real, not assumed).
3. **journald:** copy `journald/journald-socx.conf` to `/etc/systemd/journald.conf.d/socx.conf` on the host, then `systemctl restart systemd-journald`. Verify with `systemd-analyze cat-config systemd/journald.conf`.
4. Re-verify after adapting anything in `monitoring.tf`: a real `terraform apply`, confirming `plan` reaches zero-diff afterward — this round's own history shows real API contracts (`period`, default `comparison`/`threshold`) can diverge from what the schema alone implies. Update this manifest's `verified` field to reflect the new evidence.

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
- Runbooks: `docs/runbooks/incident-response/app-down-alert.md` (Approved — satisfies `OPS-040.4`'s alert-runbook pairing for the `down` alerts this category creates)
- Reference Implementations: `reference/application` (the health-check content this generalizes), `reference/terraform` (Approved — the configuration this was actually applied alongside, real on-host 2026-08-07), `reference/nginx` (the edge every uptime check target passes through), `reference/deployment` (the health gate that already polls `/healthz` during a deploy)
