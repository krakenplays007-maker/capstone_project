variable "target_network_name" {
  description = "Name of the VPC network to attach the firewall rules to"
  type        = string
}

variable "firewall_ingress_rules" {
  description = "List of firewall rules to create on the network"
  type = list(object({
    rule_name             = string
    traffic_direction     = string
    rule_priority         = number
    allowed_protocol      = string
    allowed_ports         = list(string)
    allowed_source_ranges = list(string)
    applicable_tags       = list(string)
  }))
}
