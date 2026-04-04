variable "gcp_project_id" {
  description = "GCP project ID where IAM bindings will be applied"
  type        = string
}

variable "instance_name" {
  description = "Name of the compute instance for VM-level IAM bindings"
  type        = string
}

variable "instance_zone" {
  description = "Zone of the compute instance for VM-level IAM bindings"
  type        = string
}

# Project-level IAM
variable "project_iam_bindings" {
  description = "List of IAM role-member bindings to apply at the project level"
  type = list(object({
    iam_role        = string
    member_identity = string
  }))
  default = []
}

# VM-level IAM
variable "vm_iam_bindings" {
  description = "List of IAM role-member bindings to apply directly on the compute instance"
  type = list(object({
    iam_role        = string
    member_identity = string
  }))
  default = []
}

# VM Service Account
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
