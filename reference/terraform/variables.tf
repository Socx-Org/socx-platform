# reference/terraform — variable declarations (ADR-160, ADR-140)

variable "do_token" {
  description = "DigitalOcean API token. Set via TF_VAR_do_token or a .tfvars file that is NEVER committed (SEC-010.1)."
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token, scoped to DNS edit on the target zone only. Never committed (SEC-010.1)."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the apex domain."
  type        = string
}

variable "apex_domain" {
  description = "The platform's apex domain."
  type        = string
}

variable "app_subdomains" {
  description = "Subdomains to create as A records pointing at the droplet, one per application (DOM-010)."
  type        = list(string)
  default     = ["ghs", "rms", "ams"]
}

variable "manage_apex_dns" {
  description = "Whether this module manages DNS records at all. False for a tier that shouldn't own the platform's real domains (e.g. a throwaway non-production droplet reached by IP only)."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment tier (ADR-140, OPS-010.1): production or non-production. Both use the same module -- same topology, different .tfvars -- not a separate configuration."
  type        = string

  validation {
    condition     = contains(["production", "non-production"], var.environment)
    error_message = "environment must be \"production\" or \"non-production\"."
  }
}

variable "droplet_name_prefix" {
  description = "Prefix for the droplet's name, e.g. \"prod\" or \"nonprod\" -- deliberately separate from the strictly-validated environment variable, so the real naming convention (\"prod-lab-01\", CS-INF-020) doesn't have to match environment's exact enum values."
  type        = string
}

variable "droplet_name_suffix" {
  description = "Suffix appended to droplet_name_prefix to form the droplet's full name, e.g. \"prod-lab-01\" style naming."
  type        = string
  default     = "lab-01"
}

variable "region" {
  description = "DigitalOcean region slug. Not confirmed anywhere in CS-INF-020 -- fill in from the real droplet at import time, do not guess."
  type        = string
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug. Confirmed for real via the DigitalOcean API during reference/terraform's on-host verification (2026-08-07): s-1vcpu-1gb-amd -- not s-1vcpu-1gb, the earlier inferred guess based on CS-INF-020's ~956 MiB RAM observation alone (both slugs share that spec; only a live API query distinguishes them)."
  type        = string
  default     = "s-1vcpu-1gb-amd"
}

variable "droplet_image" {
  description = "DigitalOcean image slug for the droplet's OS. Defaults to the confirmed-running release (CS-INF-020: Ubuntu 26.04 LTS) -- verify the exact slug against DigitalOcean's current image list before import, since slug naming can change."
  type        = string
  default     = "ubuntu-26-04-x64"
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key installed for the initial admin account (see automation/create-deploy-user-on-droplet.sh for the deploy-user pattern built on top of it)."
  type        = string
}
