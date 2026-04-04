variable "gcp_project_id" {
  description = "GCP project ID where all resources will be provisioned"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for all regional resources"
  type        = string
}

# VPC
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
}

variable "subnetwork_ip_cidr_range" {
  description = "IP CIDR range for the subnetwork"
  type        = string
}

# Firewall
variable "firewall_ingress_rules" {
  description = "List of firewall rules to apply to the VPC network"
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

# VM
variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "instance_machine_type" {
  description = "Machine type for the compute instance"
  type        = string
}

variable "instance_zone" {
  description = "Zone where the compute instance will be deployed"
  type        = string
}

variable "boot_disk_image" {
  description = "OS image for the boot disk"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in gigabytes"
  type        = number
}

variable "enable_external_ip" {
  description = "Whether to assign a public external IP to the instance"
  type        = bool
  default     = false
}

variable "instance_network_tags" {
  description = "Network tags for firewall rule targeting"
  type        = list(string)
  default     = []
}

variable "instance_metadata" {
  description = "Metadata key-value pairs for the instance"
  type        = map(string)
  default     = {}
}

variable "vm_service_account_scopes" {
  description = "OAuth scopes granted to the VM service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
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
  description = "List of IAM role-member bindings to apply directly on the compute instance"
  type = list(object({
    iam_role        = string
    member_identity = string
  }))
  default = []
}

variable "vm_service_account_id" {
  description = "Account ID for the VM service account (e.g. capstone-vm-sa)"
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
