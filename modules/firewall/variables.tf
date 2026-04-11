variable "firewall_ingress_rules" {
  description = "List of firewall rules to create"
  type = list(object({
    rule_name             = string
    target_network_name   = string
    traffic_direction     = string
    rule_priority         = number
    allowed_protocol      = string
    allowed_ports         = list(string)
    allowed_source_ranges = list(string)
    applicable_tags       = list(string)
  }))
}
