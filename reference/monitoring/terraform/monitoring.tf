# reference/monitoring — uptime checks and alerting (OPS-040.1, OPS-040.2)
#
# A drop-in addition to reference/terraform's configuration, not a separate
# Terraform root: copy this file into the same directory as reference/
# terraform's main.tf/variables.tf so it shares the existing
# `digitalocean` provider block, `digitalocean_droplet.app` resource, and
# the existing `apex_domain`/`app_subdomains` variables, rather than
# redeclaring any of them. The one new variable this file needs
# (alert_email) is declared below, deliberately NOT in a second
# variables.tf -- reference/terraform already owns that filename, and a
# second file with the same name would silently overwrite it on copy.
#
# Built on DigitalOcean's own Uptime Checks / Alert Policies -- already-
# adopted infrastructure (ADR-160), not a new monitoring stack nobody has
# decided on. Confirmed via the real, installed digitalocean provider
# (2.99.1): digitalocean_uptime_check, digitalocean_uptime_alert, and
# digitalocean_monitor_alert all genuinely exist with the attributes used
# below -- this is not a guess at the provider's shape.

variable "alert_email" {
  description = "Email address alerts are routed to (OPS-040.2: every alert must reach a responsible owner). Not a secret, but account-specific -- never guessed."
  type        = string
}

# One check per application, polling reference/monitoring's own /healthz
# route through reference/nginx's edge -- never the droplet's IP directly,
# per ADR-050 (no app is directly internet-facing).
resource "digitalocean_uptime_check" "app" {
  for_each = toset(var.app_subdomains)

  name    = "${each.value}-healthz"
  type    = "https"
  target  = "https://${each.value}.${var.apex_domain}/healthz"
  regions = ["us_east", "eu_west"]
  enabled = true
}

# Satisfies OPS-040.2: detects "down" and routes an alert to a responsible
# owner (email, via var.alert_email -- fill in a real address in the
# consuming .tfvars, same pattern as reference/terraform's environments/*).
resource "digitalocean_uptime_alert" "app_down" {
  for_each = digitalocean_uptime_check.app

  check_id = each.value.id
  name     = "${each.key}-down"
  type     = "down"

  notifications {
    email = [var.alert_email]
  }
}

# Pairs naturally with reference/nginx's real Let's Encrypt certificates --
# catches an expiring cert before it becomes an outage, rather than only
# alerting after TLS has already broken.
resource "digitalocean_uptime_alert" "app_ssl_expiry" {
  for_each = digitalocean_uptime_check.app

  check_id  = each.value.id
  name      = "${each.key}-ssl-expiry"
  type      = "ssl_expiry"
  threshold = 14 # days before expiry -- inferred reasonable default, not confirmed against a real alert firing

  notifications {
    email = [var.alert_email]
  }
}

# Droplet-level resource alert, not per-application -- illustrative only,
# not required by OPS-040 (which is about service-level liveness). Included
# because the real droplet's confirmed ~956 MiB RAM (CS-INF-020) is a
# genuine, already-known operational risk, not a hypothetical one.
resource "digitalocean_monitor_alert" "droplet_memory" {
  type        = "v1/insights/droplet/memory_utilization_percent"
  description = "Droplet memory utilization sustained above 90%"
  compare     = "GreaterThan"
  value       = 90
  window      = "5m"
  entities    = [digitalocean_droplet.app.id]
  enabled     = true

  alerts {
    email = [var.alert_email]
  }
}
