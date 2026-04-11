variable "vpcs" {
  description = "List of VPC networks and subnets to create"
  type = list(object({
    network_name             = string
    subnetwork_name          = string
    subnetwork_ip_cidr_range = string
  }))
}

variable "gcp_region" {
  description = "GCP region where subnets will be created"
  type        = string
}
