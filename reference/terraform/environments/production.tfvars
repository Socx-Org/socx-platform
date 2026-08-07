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

# Confirmed for real via the DigitalOcean API, 2026-08-07 (droplet id 572060222).
droplet_size = "s-1vcpu-1gb-amd"
region       = "lon1"

# Confirmed for real via the Cloudflare API / account SSH key list, 2026-08-07.
# Neither value is a secret (an API-readable identifier, not a credential) --
# safe to commit, unlike do_token/cloudflare_api_token above.
cloudflare_zone_id  = "77791e5cb6be800c2a5c54e869f7e834"
ssh_key_fingerprint = "c2:ff:de:68:9b:c3:c6:3c:a1:a6:3c:aa:90:e9:0c:cb"
