output "firewall_rule_ids" { value = { for k, v in google_compute_firewall.rule : k => v.id } }
