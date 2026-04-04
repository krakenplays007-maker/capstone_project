variable "network_name" {
  description = "Name of the GCP VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the subnetwork within the VPC"
  type        = string
}

variable "subnetwork_ip_cidr_range" {
  description = "IP CIDR range for the subnetwork (e.g. 10.0.0.0/24)"
  type        = string
}

variable "gcp_region" {
  description = "GCP region where the subnetwork will be created"
  type        = string
}
