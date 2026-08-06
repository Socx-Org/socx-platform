---
status: Draft
verified: null   # required before Approved: "<method>, YYYY-MM-DD" -- see Purpose & Scope for what's already checked vs. what verified actually requires
---

# reference/terraform — Infrastructure as Code

## Purpose & Scope

Provisions the droplet and DNS records as code (`ADR-160`), and gives `ADR-140`'s two-environment-tier requirement a mechanism: the same module, driven by per-tier `.tfvars`, rather than two different configurations.

**Already confirmed, but this is not what `verified` requires.** `terraform fmt`, `init`, and `validate` have all been run against this configuration locally, against the real `digitalocean` (2.99.1) and `cloudflare` (4.52.8) provider schemas — the configuration is genuinely syntactically and semantically valid, not just eyeballed. That's real signal, but it's a different thing from this library's `verified` gate, which — consistent with every other reference implementation here — means evidence against real infrastructure: a real `terraform import` bringing the actual droplet under management, or a real `apply`. That requires real credentials and is a deliberate, separate, higher-stakes round (see Usage) — which is also what would close `ADR-180`'s two standing `GEN-010.9` exceptions (`OPS-020` hand-provisioning, `OPS-010.1` single tier). `status` stays `Draft`, and `verified` stays `null`, until that round happens.

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
- **Two placeholders are left unfilled deliberately, not guessed:** the DigitalOcean **region** (never confirmed anywhere in `CS-INF-020` — B0 didn't check it) and the Cloudflare **zone ID** / **SSH key fingerprint** (account-specific, not something to fabricate). The droplet **size** (`s-1vcpu-1gb`) is filled in but flagged as *inferred* — it matches the observed ~956 MiB RAM / 1 vCPU exactly, a standard slug, but wasn't directly read from the account.

## Compliance

| Requirement | Satisfied by |
|---|---|
| OPS-020.1 | This module itself — infrastructure defined as code, version-controlled, reviewed via PR, not edited manually as the source of truth (once adopted for real) |
| OPS-020.5 | `terraform apply` is the idempotent, repeatable process — not a one-off sequence of manual commands |
| OPS-010.1 | The `environment` variable + per-tier `.tfvars` — the same module provisions either tier |

## Prerequisites

- Terraform `>= 1.5`
- A DigitalOcean API token and a Cloudflare API token (scoped to DNS edit on the target zone only), provisioned via `reference/security`'s credential pattern — never in a `.tfvars` file
- The real DigitalOcean region, Cloudflare zone ID, and SSH key fingerprint for the target account (Prerequisites deliberately doesn't fabricate these — see Design Decisions)

## Usage

1. Copy this directory into the consuming repository (or a dedicated infrastructure repository), substituting the `{{PLACEHOLDER}}` values in the relevant `environments/*.tfvars` file.
2. `terraform init` (local state is acceptable for the initial import; migrate to a remote backend such as DigitalOcean Spaces before more than one person or automation pipeline applies against this configuration — `ADR-160` leaves the exact backend choice open).
3. **To bring the existing production droplet under management (closing `ADR-180`'s `OPS-020` exception) — import, don't recreate:**
   ```
   terraform import -var-file=environments/production.tfvars digitalocean_droplet.app <real-droplet-id>
   terraform import -var-file=environments/production.tfvars cloudflare_record.apex[0] <zone-id>/<record-id>
   # ... one import per existing DNS record
   ```
4. `terraform plan -var-file=environments/production.tfvars` — after import, this should show **no changes**. Any diff means the `.tfvars` values don't yet match the real resource; reconcile before ever running `apply`.
5. To provision a genuinely new second tier (closing `ADR-180`'s `OPS-010.1` exception): fill in real values in `environments/non-production.tfvars`, then `terraform apply -var-file=environments/non-production.tfvars` — this creates real, billable infrastructure and is its own deliberate decision, not a default outcome of authoring this module.
6. Record the method and date in this manifest's `verified` field once a real import or apply has actually been run — see Purpose & Scope for why that's a distinct, later step from what's verified here.

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
- ADRs: `ADR-160` (Terraform adopted for provisioning), `ADR-140` (environment tier model), `ADR-180` (the two standing exceptions this module exists to close)
- Current-State: `CS-INF-020` (every confirmed value in `production.tfvars` traces back to this document)
- Runbooks: none yet — the import/apply procedure is a Deliverable 7 candidate once run for real
- Reference Implementations: `reference/systemd`, `reference/nginx`, `reference/security` (all OS-level — deliberately not re-implemented here)
