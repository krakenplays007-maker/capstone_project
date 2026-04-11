variable "environment_name" {
  description = "Environment name (dev, test, or prod)"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID where all resources will be provisioned"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for all regional resources"
  type        = string
}

# VPC
variable "vpcs" {
  description = "List of VPC networks and their subnets to create"
  type = list(object({
    network_name             = string
    subnetwork_name          = string
    subnetwork_ip_cidr_range = string
  }))
}

# Firewall
variable "firewall_ingress_rules" {
  description = "List of firewall rules to apply to the VPC network"
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

# VM
variable "vms" {
  description = "List of compute instances to create"
  type = list(object({
    instance_name               = string
    instance_machine_type       = string
    instance_zone               = string
    boot_disk_image             = string
    boot_disk_size_gb           = number
    instance_subnetwork_name    = string
    enable_external_ip          = bool
    instance_network_tags       = list(string)
    instance_metadata           = map(string)
    vm_service_account_scopes   = list(string)
  }))
}

# IAM
variable "project_iam_bindings" {
  description = "List of IAM role-member bindings to apply at the project level"
  type = list(object({
    iam_role        = string
    member_identity = string
  }))
  default = []
}

variable "vm_iam_bindings" {
  description = "List of IAM role-member bindings to apply directly on compute instances"
  type = list(object({
    instance_name   = string
    instance_zone   = string
    iam_role        = string
    member_identity = string
  }))
  default = []
}

variable "vm_service_account_id" {
  description = "Account ID for the VM service account (e.g. dev-vm-sa)"
  type        = string
}

variable "vm_service_account_display_name" {
  description = "Human-readable display name for the VM service account"
  type        = string
}

variable "vm_service_account_roles" {
  description = "List of IAM roles to grant to the VM service account at project level"
  type        = list(string)
  default     = []
}
