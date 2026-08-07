# reference/terraform — droplet and DNS provisioning (ADR-160, ADR-140)
#
# Manages the droplet and DNS records only. OS-level configuration is
# reference/systemd, reference/nginx, and reference/security's job --
# already built and verified; re-implementing it here via provisioners
# would duplicate a pattern that already works.
#
# DNS is Cloudflare, not DigitalOcean's own DNS service (CS-INF-020:
# nameservers brett.ns.cloudflare.com / cruz.ns.cloudflare.com).

terraform {
  required_version = ">= 1.5"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  # State backend deliberately not fixed here -- ADR-160 leaves this open
  # as a follow-up decision. Local state is acceptable for the initial
  # import (see README.md Usage); migrate to a remote backend (e.g.
  # DigitalOcean Spaces) before more than one person or pipeline applies
  # against this configuration.
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "digitalocean_droplet" "app" {
  name     = "${var.droplet_name_prefix}-${var.droplet_name_suffix}"
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = [var.ssh_key_fingerprint]
  # Create-time only, like ssh_keys -- the real droplet has this enabled
  # (confirmed via its real ipv6_address). Undeclared here defaults to
  # false, which -- like the ssh_keys gap above -- would force a destructive
  # recreate to "fix". Also found during this module's on-host verification.
  ipv6 = true

  lifecycle {
    # Real infrastructure with real DNS and real certificates pointing at
    # it (production) -- an accidental apply-triggered recreate would be
    # expensive to recover from. Non-production may reasonably override
    # this per its own tfvars if disposability is actually wanted there.
    prevent_destroy = true

    # DigitalOcean's API does not return ssh_keys after droplet creation --
    # it's write-once, used only to seed the droplet's initial authorized
    # keys, never reconciled afterward. Without this, Terraform sees the
    # imported state's ssh_keys as empty, diffs it against this resource's
    # declared value, and -- because changing ssh_keys is not an in-place
    # operation the API supports -- plans to destroy and recreate the real
    # droplet. Caught for real during this module's on-host verification:
    # `prevent_destroy` correctly blocked the apply, but the plan itself
    # would have proposed exactly that. ignore_changes is the standard,
    # documented pattern for this specific provider limitation.
    ignore_changes = [ssh_keys]
  }
}

# Apex domain (socx.org.uk) -- A record, DNS-only (not proxied), matching
# what CS-INF-020 directly observed via dig. `name` is the full domain, not
# the zonefile-style "@" shorthand -- Cloudflare's API stores (and diffs
# against) the literal apex name, not "@"; found for real during this
# module's on-host verification, where "@" forced a destroy/recreate plan
# against an already-correct, already-existing record.
resource "cloudflare_record" "apex" {
  count   = var.manage_apex_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.apex_domain
  content = digitalocean_droplet.app.ipv4_address
  type    = "A"
  proxied = false
  ttl     = 1
  # Real, pre-existing comment on this record (confirmed via the Cloudflare
  # API during on-host verification) -- declared here so import doesn't
  # silently wipe it on the first apply.
  comment = "pointing to prod-lab-01 on Digital Ocean"
}

# www -- CNAME to the apex, not a duplicate A record (CS-INF-020's
# observed record type; getting this wrong is exactly the kind of drift
# this module exists to prevent).
resource "cloudflare_record" "www" {
  count   = var.manage_apex_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.apex_domain
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

# Per-application subdomains, one A record each -- mirrors reference/nginx's
# one-site-file-per-app pattern at the DNS layer.
resource "cloudflare_record" "app" {
  for_each = var.manage_apex_dns ? toset(var.app_subdomains) : []
  zone_id  = var.cloudflare_zone_id
  name     = each.value
  content  = digitalocean_droplet.app.ipv4_address
  type     = "A"
  proxied  = false
  ttl      = 1
}

# www.<app> -- CNAME to the app subdomain, same pattern as the apex's own
# www record. Found missing from this module during real on-host
# verification (a live Cloudflare API query showed these three records
# already existed for real, unmanaged) -- added here rather than left
# undeclared.
resource "cloudflare_record" "app_www" {
  for_each = var.manage_apex_dns ? toset(var.app_subdomains) : []
  zone_id  = var.cloudflare_zone_id
  name     = "www.${each.value}"
  content  = "${each.value}.${var.apex_domain}"
  type     = "CNAME"
  proxied  = false
  ttl      = 1
}
