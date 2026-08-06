# reference/terraform — outputs

output "droplet_id" {
  description = "DigitalOcean droplet ID."
  value       = digitalocean_droplet.app.id
}

output "droplet_ip" {
  description = "Public IPv4 address of the provisioned droplet."
  value       = digitalocean_droplet.app.ipv4_address
}

output "droplet_name" {
  value = digitalocean_droplet.app.name
}
