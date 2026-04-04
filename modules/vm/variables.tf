variable "instance_name" {
  description = "Name of the GCP compute instance"
  type        = string
}

variable "instance_machine_type" {
  description = "GCP machine type for the instance (e.g. e2-medium)"
  type        = string
}

variable "instance_zone" {
  description = "GCP zone where the instance will be deployed"
  type        = string
}

variable "boot_disk_image" {
  description = "OS image for the boot disk (e.g. debian-cloud/debian-12)"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Size of the boot disk in gigabytes"
  type        = number
}

variable "instance_subnetwork" {
  description = "Self-link or name of the subnetwork to attach the instance to"
  type        = string
}

variable "enable_external_ip" {
  description = "Whether to assign a public external IP to the instance"
  type        = bool
  default     = false
}

variable "instance_network_tags" {
  description = "Network tags applied to the instance for firewall targeting"
  type        = list(string)
  default     = []
}

variable "instance_metadata" {
  description = "Key-value metadata to assign to the instance (e.g. startup scripts)"
  type        = map(string)
  default     = {}
}

variable "vm_service_account_email" {
  description = "Email of the service account to attach to the compute instance"
  type        = string
}

variable "vm_service_account_scopes" {
  description = "List of OAuth scopes granted to the VM service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}
