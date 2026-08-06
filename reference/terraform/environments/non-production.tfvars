# reference/terraform — non-production tier values (ADR-140, OPS-010.1)
#
# Template/example values for a tier that does not exist yet -- ADR-140
# requires the *capability* to provision a second tier of the same
# topology; it does not require one to already be running. Nothing here
# is a confirmed fact the way production.tfvars's CS-INF-020-sourced
# values are -- adjust before ever running this for real.
#
# Same secrets rule as production.tfvars: do_token / cloudflare_api_token
# via TF_VAR_* environment variables, never committed here.

environment         = "non-production"
droplet_name_prefix = "nonprod"
droplet_name_suffix = "lab-01"

# A non-production tier reasonably doesn't need its own public DNS records
# on the platform's real domains -- reached by IP or a separate test
# domain instead. Flip to true and adjust app_subdomains if that changes.
manage_apex_dns = false
apex_domain     = "{{NON_PRODUCTION_DOMAIN_IF_ANY}}"
app_subdomains  = []

# Same size as production by default (ADR-140: same topology, differing
# only in scale and data) -- reduce here if a smaller tier is preferred.
droplet_size = "s-1vcpu-1gb"

region              = "{{REGION}}"
cloudflare_zone_id  = "{{CLOUDFLARE_ZONE_ID}}"
ssh_key_fingerprint = "{{SSH_KEY_FINGERPRINT}}"
