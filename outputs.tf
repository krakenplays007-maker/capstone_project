output "vpc_ids" {
  description = "Map of VPC network names to their IDs"
  value       = length(module.vpc) > 0 ? module.vpc[0].vpc_ids : {}
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = length(module.vpc) > 0 ? module.vpc[0].subnet_ids : {}
}

output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs"
  value       = length(module.firewall) > 0 ? module.firewall[0].firewall_rule_ids : {}
}

output "instance_ids" {
  description = "Map of instance names to their IDs"
  value       = length(module.vm) > 0 ? module.vm[0].instance_ids : {}
}

output "internal_ips" {
  description = "Map of instance names to their internal IPs"
  value       = length(module.vm) > 0 ? module.vm[0].internal_ips : {}
}

output "vm_service_account_email" {
  description = "Email of the VM service account"
  value       = length(module.iam) > 0 ? module.iam[0].vm_service_account_email : null
}
