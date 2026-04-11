variable "vms" {
  description = "List of compute instances to create"
  type = list(object({
    instance_name             = string
    instance_machine_type     = string
    instance_zone             = string
    boot_disk_image           = string
    boot_disk_size_gb         = number
    instance_subnetwork       = string
    enable_external_ip        = bool
    instance_network_tags     = list(string)
    instance_metadata         = map(string)
    vm_service_account_scopes = list(string)
  }))
}

variable "vm_service_account_email" {
  description = "Service account email attached to all VMs"
  type        = string
}

variable "vm_iam_bindings" {
  description = "List of IAM role-member bindings at the VM instance level"
  type = list(object({
    instance_name   = string
    instance_zone   = string
    iam_role        = string
    member_identity = string
  }))
  default = []
}

variable "gcp_project_id" {
  description = "GCP project ID for VM-level IAM bindings"
  type        = string
}
