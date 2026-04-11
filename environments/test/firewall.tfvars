firewall_ingress_rules = [
  {
    rule_name             = "test-allow-ssh"
    target_network_name   = "test-vpc"
    traffic_direction     = "INGRESS"
    rule_priority         = 1000
    allowed_protocol      = "tcp"
    allowed_ports         = ["22"]
    allowed_source_ranges = ["10.0.0.0/8"]
    applicable_tags       = ["ssh"]
  },
  {
    rule_name             = "test-allow-http-https"
    target_network_name   = "test-vpc"
    traffic_direction     = "INGRESS"
    rule_priority         = 1000
    allowed_protocol      = "tcp"
    allowed_ports         = ["80", "443"]
    allowed_source_ranges = ["0.0.0.0/0"]
    applicable_tags       = ["web"]
  }
]
