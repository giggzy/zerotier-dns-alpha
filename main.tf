module "network" {
  source      = "zerotier/network/zerotier"
  name        = "test_dns_alpha"
  description = "Network to test DNS Alpha"
  subnets     = ["10.9.8.0/24"]
  flow_rules  = "accept;"
}

