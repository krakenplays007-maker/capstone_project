# VPC Outputs
output "vpc_id" {
  description = "The unique identifier of the VPC network"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = module.vpc.vpc_name
}

output "subnet_id" {
  description = "The unique identifier of the subnetwork"
  value       = module.vpc.subnet_id
}

# Firewall Outputs
output "firewall_rule_ids" {
  description = "Map of firewall rule names to their resource IDs"
  value       = module.firewall.firewall_rule_ids
}

# VM Outputs
output "instance_id" {
  description = "The unique identifier of the compute instance"
  value       = module.vm.instance_id
}

output "instance_name" {
  description = "The name of the compute instance"
  value       = module.vm.instance_name
}

output "internal_ip" {
  description = "The internal IP address of the compute instance"
  value       = module.vm.internal_ip
}

# IAM Outputs
output "vm_service_account_email" {
  description = "The email address of the VM service account"
  value       = module.iam.vm_service_account_email
}

output "vm_service_account_id" {
  description = "The unique ID of the VM service account"
  value       = module.iam.vm_service_account_id
}
