variable "gcp_project_id" {
  description = "GCP project ID where IAM bindings will be applied"
  type        = string
}

variable "project_iam_bindings" {
  description = "List of IAM role-member bindings at the project level"
  type = list(object({
    iam_role        = string
    member_identity = string
  }))
  default = []
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

variable "vm_service_account_id" {
  description = "Account ID for the VM service account"
  type        = string
}

variable "vm_service_account_display_name" {
  description = "Display name for the VM service account"
  type        = string
}

variable "vm_service_account_roles" {
  description = "Roles granted to the VM service account at project level"
  type        = list(string)
  default     = []
}
