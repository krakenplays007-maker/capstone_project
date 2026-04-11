resource "google_compute_network" "vpc" {
  for_each                = { for v in var.vpcs : v.network_name => v }
  name                    = each.value.network_name
  auto_create_subnetworks = false

  lifecycle {
    ignore_changes = [name]
  }
}

resource "google_compute_subnetwork" "subnet" {
  for_each      = { for v in var.vpcs : v.subnetwork_name => v }
  name          = each.value.subnetwork_name
  ip_cidr_range = each.value.subnetwork_ip_cidr_range
  region        = var.gcp_region
  network       = google_compute_network.vpc[each.value.network_name].id

  lifecycle {
    ignore_changes = [name, ip_cidr_range]
  }
}
