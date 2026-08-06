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

  lifecycle {
    # Real infrastructure with real DNS and real certificates pointing at
    # it (production) -- an accidental apply-triggered recreate would be
    # expensive to recover from. Non-production may reasonably override
    # this per its own tfvars if disposability is actually wanted there.
    prevent_destroy = true
  }
}

# Apex domain (socx.org.uk) -- A record, DNS-only (not proxied), matching
# what CS-INF-020 directly observed via dig.
resource "cloudflare_record" "apex" {
  count   = var.manage_apex_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = digitalocean_droplet.app.ipv4_address
  type    = "A"
  proxied = false
  ttl     = 300
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
  ttl     = 300
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
  ttl      = 300
}
