output "zerotier_network_id" {
  value = module.network.id
}

output "do_server_ip" {
  value = digitalocean_droplet.test-zt-dns.ipv4_address
}

output "domain_name" {
  value = var.domain_name
}
