# reference/terraform — production tier values (ADR-140, OPS-010.1)
#
# Non-secret only. do_token / cloudflare_api_token are NEVER placed in a
# .tfvars file -- set via TF_VAR_do_token / TF_VAR_cloudflare_api_token
# environment variables, sourced from reference/security's credential
# pattern, not committed here (SEC-010.1).

environment         = "production"
droplet_name_prefix = "prod"
droplet_name_suffix = "lab-01"

# Confirmed via CS-INF-020 direct observation.
apex_domain     = "socx.org.uk"
app_subdomains  = ["ghs", "rms", "ams"]
manage_apex_dns = true

# Inferred, not confirmed -- verify against the real droplet before import.
droplet_size = "s-1vcpu-1gb"

# Never confirmed anywhere in CS-INF-020 -- fill in from the real droplet,
# do not guess.
region = "{{REGION}}"

# cloudflare_zone_id, ssh_key_fingerprint: fill in from the real account
# before use -- not fabricated here.
cloudflare_zone_id  = "{{CLOUDFLARE_ZONE_ID}}"
ssh_key_fingerprint = "{{SSH_KEY_FINGERPRINT}}"
