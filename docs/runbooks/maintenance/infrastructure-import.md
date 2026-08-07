---
status: Approved
verified: "Real execution against the real production droplet and all 8 real Cloudflare DNS records, 2026-08-07, as part of reference/terraform's verification round -- the exact procedure and gotchas below are transcribed from that session, not paraphrased. Includes real API calls, real terraform import commands, and the real bugs found before any apply was attempted."
---

# maintenance/infrastructure-import.md — Bringing Existing Infrastructure Under Terraform

## Purpose & Scope

The procedure for `terraform import`-ing an already-existing, hand-created (or previously-unmanaged) cloud resource into `reference/terraform`'s state — without destroying or recreating it. Also covers reaching a genuine zero-diff `plan` afterward, which is where the real risk actually lives: import itself is safe (read-only against the real resource), but the *first `plan`/`apply` after import* is where a config/reality mismatch can propose destroying something real.

Does not cover provisioning genuinely new infrastructure from scratch (a plain `terraform apply` with no prior `import` step) — that's lower-risk and doesn't need this runbook's drift-reconciliation steps.

## Trigger

An existing DigitalOcean droplet, Cloudflare DNS record, or similar resource needs to come under this repository's Terraform management — most commonly, closing an `ADR-180`-style `GEN-010.9` "hand-provisioned" exception for real.

## Prerequisites

- Real API credentials for every provider involved (`TF_VAR_do_token`, `TF_VAR_cloudflare_api_token`, etc.) — set as environment variables, never written into a `.tfvars` file
- The real resource's ID/identifier — **query it via the provider's API directly; do not trust a dashboard-remembered or previously-documented value.** This round found a droplet size (`s-1vcpu-1gb-amd`, not the previously-inferred `s-1vcpu-1gb`) and a full extra set of DNS records that no prior document had listed
- `reference/terraform`'s files already checked out, with any account-specific values (region, zone ID, SSH key fingerprint) filled in from that same real API query — never guessed

## Procedure

1. **Query the provider's API directly for the resource's real attributes before writing or trusting any config.** Example, DigitalOcean:
   ```
   curl -s -H "Authorization: Bearer $DO_TOKEN" "https://api.digitalocean.com/v2/droplets" | \
     python3 -c "import json,sys; [print(d['id'], d['name'], d['region']['slug'], d['size_slug']) for d in json.load(sys.stdin)['droplets']]"
   ```
   **If this returns more resources than you expected** (this round found a second, previously-undocumented droplet), stop and get an explicit decision on each one before proceeding — don't assume, don't silently import everything the query returns, and don't silently ignore what you didn't expect either.

2. **Import each resource by its real ID, not a guessed or documented-but-unconfirmed one:**
   ```
   terraform import -var-file=environments/production.tfvars digitalocean_droplet.app <real-id>
   terraform import -var-file=environments/production.tfvars cloudflare_record.apex[0] <zone-id>/<record-id>
   ```

3. **Run `terraform plan` and read every line before considering `apply`.** A clean import does not guarantee a clean plan — config written against inference or documentation, not the live resource, will show drift. This round's `plan` initially showed the real droplet being destroyed and recreated, for three independent reasons:
   - `ssh_keys` — DigitalOcean's API never returns this attribute after creation. Undeclared-after-import state shows it empty, which diffs against a non-empty declared value as `forces replacement`. Fix: `lifecycle { ignore_changes = [ssh_keys] }` — this is a known, permanent characteristic of the provider, not a one-time fix.
   - `ipv6` — a create-time-only attribute; if the real resource has it enabled but the config never declares it, the config's implicit `false` default also forces replacement. Fix: declare it explicitly, matching the real value.
   - A Cloudflare record's `name` set to the zonefile-style `"@"` shorthand for an apex record — the real API stores the literal domain name, not `"@"`. Fix: use the real value.

   **If `plan` proposes destroying or replacing something real, stop.** Do not run `apply` "to see what happens." Fix the config to match reality instead — the resource is real; the config was wrong.

4. **Watch for real, pre-existing metadata a naive config would silently discard** — this round found a real, human-written comment on a DNS record that a `plan` without an explicit `comment` attribute would have wiped on first `apply`. Query the resource's full attribute set (not just the ones you expected to need) before concluding the config is complete.

5. **Re-run `plan` after each fix, in a tight loop, until it reports zero destroys and zero replacements.** Cosmetic in-place changes (a provider recording an explicit default value that was previously implicit) are generally safe to `apply`; anything with `will be replaced` or `must be destroyed` is not, until you understand exactly why and have fixed the config, not forced the apply.

6. **Only once `plan` shows zero destroys/replacements**, `apply` the remaining safe, in-place changes, then re-run `plan` one more time to confirm a genuine zero-diff state.

## Verification

- `terraform plan` reports `No changes. Your infrastructure matches the configuration.`
- The real resource still functions exactly as before — for a droplet, real SSH access and running services; for DNS, real resolution (`dig`) still returns the expected values.
- Nothing in the resource's real attribute set (checked via the provider's own API, not just Terraform's state) was silently altered or lost by the process.

## Escalation / Rollback

If an `apply` is run against a `plan` that included an unintended destroy/replace, the resource is gone — `terraform` does not have an undo. This is exactly why step 3's "stop and fix the config, don't apply to see what happens" is the load-bearing rule in this entire procedure, not a suggestion. If you're ever unsure whether a specific attribute's diff is safe, treat it as unsafe until proven otherwise by reading the provider's real documentation or, better, by observing what a `plan` (never `apply`) proposes and reasoning about *why*.

## Related Documents

- Standards: `OPS-020` (`OPS-020.1`, `.5`), `OPS-010` (`OPS-010.1`)
- ADRs: `ADR-160` (Terraform adopted for provisioning), `ADR-180` (the exceptions this procedure closes)
- Reference Implementations: `reference/terraform` (the configuration this operates, including the fixes this round found)
- Runbooks: none directly, though a failed import that leaves a service down would hand off to `incident-response/app-down-alert.md`
