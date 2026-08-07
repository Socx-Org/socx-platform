---
status: Approved
verified: "Real terraform import of the real production droplet (id 572060222) and all 8 real Cloudflare DNS records, against real DigitalOcean and Cloudflare API credentials. terraform plan reached a genuine zero-diff state ('No changes. Your infrastructure matches the configuration.') after fixing several real bugs the import surfaced (see Design Decisions); real DNS resolution reconfirmed afterward via dig. Closes ADR-180's OPS-020 exception (the droplet is now IaC-managed). Does NOT close ADR-180's OPS-010.1 exception -- a real second environment tier was deliberately not provisioned in this round (see Purpose & Scope). 2026-08-07"
---

# reference/terraform — Infrastructure as Code

## Purpose & Scope

Provisions the droplet and DNS records as code (`ADR-160`), and gives `ADR-140`'s two-environment-tier requirement a mechanism: the same module, driven by per-tier `.tfvars`, rather than two different configurations.

**What `verified` covers, and what it deliberately doesn't.** The real production droplet and all 8 real DNS records are now genuinely under Terraform management — imported, not recreated, with `terraform plan` reaching a real zero-diff state against live infrastructure. It does **not** cover provisioning a real second environment tier: `ADR-180`'s `OPS-010.1` exception (single environment tier) stays open. A previously-unrelated droplet (`dev-lab-01`) was found to exist in the account during this round's real API inspection, but was explicitly not brought under this module's management or otherwise touched — its disposition is untriaged, a separate decision for the platform owner, not something this round should default into deciding.

Explicitly not covered here:

- **OS-level configuration** — `reference/systemd`, `reference/nginx`, `reference/security` already own this, verified and working; this module does not use `remote-exec` provisioners or otherwise re-implement any of it
- **State backend selection** — `ADR-160` itself leaves this open as a follow-up decision; see Usage for the interim approach
- **A new firewall layer** — DigitalOcean offers a native Cloud Firewall resource, but introducing a second firewall alongside the already-working UFW setup (`reference/systemd`'s host) would be a new architectural element nobody has decided on; noted as a candidate future enhancement, not adopted here

## Contents

| File | Role |
|---|---|
| `main.tf` | Provider configuration, the droplet resource, DNS records |
| `variables.tf` | Inputs, including `environment` (`production`/`non-production`) |
| `outputs.tf` | Droplet ID/IP/name |
| `environments/production.tfvars` | Production values — non-secret fields filled in from `CS-INF-020` where confirmed |
| `environments/non-production.tfvars` | Template values for a tier that doesn't exist yet |
| `.terraform.lock.hcl` | Pinned provider versions, committed for reproducibility |

## Design Decisions

- **Manages the droplet and DNS only, not what runs on it.** `reference/systemd`/`reference/nginx`/`reference/security` are already built and verified; re-implementing that in Terraform would duplicate a working pattern rather than manage the layer underneath it.
- **DNS targets the Cloudflare provider, not DigitalOcean's own DNS.** `CS-INF-020` directly observed the real nameservers (`brett.ns.cloudflare.com`, `cruz.ns.cloudflare.com`) — using DO's DNS product here would describe infrastructure that doesn't exist.
- **`www` is a `CNAME` to the apex, not a duplicate `A` record.** Matches `CS-INF-020`'s exact observed record type — getting this wrong is precisely the kind of drift this module exists to prevent.
- **`prevent_destroy = true` on the production droplet.** Real DNS and real certificates already point at it; an accidental `apply`-triggered recreate would be expensive to recover from.
- **`environment` and the droplet's naming are deliberately decoupled.** `environment` is strictly validated to `production`/`non-production` (used for tagging/consistency elsewhere in the platform); the real droplet's confirmed name (`prod-lab-01`) doesn't share that vocabulary, so naming uses its own `droplet_name_prefix`/`droplet_name_suffix` variables rather than string-building off the validated enum.
- **Region, zone ID, SSH key fingerprint, and droplet size are now real, confirmed values, not placeholders or inferences.** Queried directly from the DigitalOcean and Cloudflare APIs during on-host verification: region `lon1`, zone ID `77791e5cb6be800c2a5c54e869f7e834`, SSH key fingerprint matching the account's real key, and droplet size `s-1vcpu-1gb-amd` — correcting an earlier inferred guess of plain `s-1vcpu-1gb` (both slugs share the same RAM/vCPU spec `CS-INF-020` observed; only a live API query distinguishes them).
- **`ignore_changes = [ssh_keys]` on the droplet.** DigitalOcean's API never returns `ssh_keys` after creation — it's write-once. Without this, Terraform sees the imported state's `ssh_keys` as empty, diffs it against the declared value, and — since changing SSH keys isn't an in-place operation the API supports — plans to **destroy and recreate the real droplet**. Found for real during import; `prevent_destroy` correctly blocked the resulting plan from ever applying, but the plan itself would have proposed exactly that.
- **`ipv6 = true` declared explicitly.** The real droplet has IPv6 enabled; leaving it undeclared defaults to `false` and — like `ssh_keys` — forces a destructive recreate to "fix," since IPv6 is also create-time-only. Found the same way, fixed the same round.
- **The apex record's `name` is `var.apex_domain`, not the zonefile-style `"@"` shorthand.** Cloudflare's API stores (and diffs against) the literal apex domain name, not `"@"` — using `"@"` forced a destroy/recreate plan against an already-correct, already-existing record. Found for real during import.
- **`www.<app>` CNAME records, one per app subdomain, mirroring the apex's own `www`.** Missing from every earlier draft of this module — a live Cloudflare API query during on-host verification showed these three records already existed for real, unmanaged. Added rather than left undeclared.
- **The apex record's pre-existing `comment` is preserved explicitly.** A real, human-written comment ("pointing to prod-lab-01 on Digital Ocean") already existed on the record; without declaring it, the first `apply` after import would have silently wiped it. Declared verbatim instead.

## Compliance

| Requirement | Satisfied by |
|---|---|
| OPS-020.1 | This module itself — infrastructure defined as code, version-controlled, reviewed via PR, not edited manually as the source of truth (once adopted for real) |
| OPS-020.5 | `terraform apply` is the idempotent, repeatable process — not a one-off sequence of manual commands |
| OPS-010.1 | The `environment` variable + per-tier `.tfvars` — the same module provisions either tier |

## Prerequisites

- Terraform `>= 1.5`
- A DigitalOcean API token and a Cloudflare API token (scoped to DNS edit on the target zone only), provisioned via `reference/security`'s credential pattern — never in a `.tfvars` file
- The real DigitalOcean region, Cloudflare zone ID, and SSH key fingerprint — already confirmed and filled into `environments/production.tfvars` for the real production account (see Design Decisions)

## Usage

1. Copy this directory into the consuming repository (or a dedicated infrastructure repository). `environments/production.tfvars` already carries the real, confirmed production values; a new target account still needs its own real values substituted.
2. `terraform init` (local state is acceptable for the initial import; migrate to a remote backend such as DigitalOcean Spaces before more than one person or automation pipeline applies against this configuration — `ADR-160` leaves the exact backend choice open).
3. To bring an existing droplet/DNS records under management — import, don't recreate:
   ```
   terraform import -var-file=environments/production.tfvars digitalocean_droplet.app <real-droplet-id>
   terraform import -var-file=environments/production.tfvars cloudflare_record.apex[0] <zone-id>/<record-id>
   # ... one import per existing DNS record
   ```
4. `terraform plan -var-file=environments/production.tfvars` — after import, this should show **no changes**. If it doesn't, don't assume the diff is cosmetic: this round found three that would have destroyed and recreated the real droplet (`ssh_keys`, `ipv6`, the apex record's `name`) before they were fixed. Reconcile the module, not the real resource, before ever running `apply`.
5. To provision a genuinely new second tier (closing `ADR-180`'s still-open `OPS-010.1` exception): fill in real values in `environments/non-production.tfvars`, then `terraform apply -var-file=environments/non-production.tfvars` — this creates real, billable infrastructure and is its own deliberate decision, not a default outcome of authoring this module.

## Expected Adaptations

**Consuming projects are expected to customise:**

- Every value in `environments/*.tfvars`
- `app_subdomains` and `manage_apex_dns` — per what a given tier actually needs
- `droplet_size` — once verified against the real account, or deliberately sized differently for non-production

**Must remain unchanged to preserve compliance:**

- `prevent_destroy` on the production droplet — removing it needs a recorded `GEN-010.9` exception, or a permanent change needs an ADR (`DOC-020.2`)
- DNS managed via the Cloudflare provider, not DigitalOcean's — reflects the real, confirmed DNS provider
- No secrets in any `.tfvars` file — `do_token`/`cloudflare_api_token` are `sensitive` variables sourced from the environment only

## Related Documents

- Standards: `OPS-010`, `OPS-020`
- Architecture: `INF-010` (target topology), `TEC-010` (approved hosting/DNS technology)
- ADRs: `ADR-160` (Terraform adopted for provisioning), `ADR-140` (environment tier model), `ADR-180` (`OPS-020` exception now closed by this module; `OPS-010.1` remains open)
- Current-State: `CS-INF-020` (every confirmed value in `production.tfvars` traces back to this document, now including the real import)
- Runbooks: `docs/runbooks/maintenance/infrastructure-import.md` (Approved — the exact procedure and gotchas from this category's own real import round)
- Reference Implementations: `reference/systemd`, `reference/nginx`, `reference/security` (all OS-level — deliberately not re-implemented here)
