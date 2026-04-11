output "vpc_ids" {
  description = "Map of VPC network names to their IDs"
  value       = module.vpc.vpc_ids
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vpc.subnet_ids
}

output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs"
  value       = module.firewall.firewall_rule_ids
}

output "instance_ids" {
  description = "Map of instance names to their IDs"
  value       = module.vm.instance_ids
}

output "internal_ips" {
  description = "Map of instance names to their internal IPs"
  value       = module.vm.internal_ips
}

output "vm_service_account_email" {
  description = "Email of the VM service account"
  value       = module.iam.vm_service_account_email
}
