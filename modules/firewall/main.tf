resource "google_compute_firewall" "rule" {
  for_each = { for r in var.firewall_ingress_rules : r.rule_name => r }

  name      = each.value.rule_name
  network   = var.target_network_name
  direction = each.value.traffic_direction
  priority  = each.value.rule_priority

  allow {
    protocol = each.value.allowed_protocol
    ports    = each.value.allowed_ports
  }

  source_ranges = each.value.allowed_source_ranges
  target_tags   = each.value.applicable_tags
}
