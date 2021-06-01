terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.5.1"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {}
variable "do_access_key" {}
variable "do_secret_key" {}
variable "do_region" {
  default = "nyc1"
}

variable "zero_nsd_token" {
  description = "Token to access ZeroTier API"
}

variable "domain_name" {
  default = "uplift.io"
}
#variable "ssh_fingerprint" {} # Going away?
#variable "ssh_fingerprint" {
#  description = "The ssh fingerprint to put on the droplet"
#}

variable "public_ssh_key" {
  description = "Public key to allow ssh access, maybe allow multiple keys in future"
}

module "network" {
  source      = "zerotier/network/zerotier"
  name        = "test_dns_alpha"
  description = "Network to test DNS Alpha"
  subnets     = ["10.9.8.0/24"]
  flow_rules  = "accept;"
}

/*
* Maybe read in a file for members?
* Don't have a strong case for automating this yet, manual is OK for now
module "member" {
  source      = "zerotier/member/zerotier"
  name        = "xxx"
  description = "xxx Desktop"
  member_id   = "xxx"
  network_id  = module.network.id
}
*/

resource "digitalocean_droplet" "test-zt-dns" {
  name      = "test-zt-dns"
  size      = "s-1vcpu-1gb"
  image     = "docker-20-04"
  region    = var.do_region
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data_zt_dns.yml")
  vars = {
    #sshd_config            = filebase64("${path.module}/templates/sshd_config.example")
    # Don't fully understand digitalocean keys, some magic?
    # Problems when I did not upload public key to DO and tried to login. terraform failed.
    public_ssh_key      = var.public_ssh_key
    zerotier_network_id = module.network.id
    domain_name = var.domain_name
    install_zerotier = base64encode(data.template_file.install_zerotier.rendered)
    token_file = base64encode(data.template_file.zerotier_token.rendered)  }
}

data "template_file" "install_zerotier" {
  template = file("${path.module}/templates/install_zerotier.sh")
  vars = {
    zerotier_network_id = module.network.id
    domain_name = var.domain_name
  }
}

data "template_file" "zerotier_token" {
  template = file("${path.module}/templates/token")
  vars = {
    token = var.zero_nsd_token
  }
}
