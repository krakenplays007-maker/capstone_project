resource "google_compute_instance" "vm" {
  for_each     = { for v in var.vms : v.instance_name => v }
  name         = each.value.instance_name
  machine_type = each.value.instance_machine_type
  zone         = each.value.instance_zone

  boot_disk {
    initialize_params {
      image = each.value.boot_disk_image
      size  = each.value.boot_disk_size_gb
    }
  }

  network_interface {
    subnetwork = each.value.instance_subnetwork

    dynamic "access_config" {
      for_each = each.value.enable_external_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.vm_service_account_email
    scopes = each.value.vm_service_account_scopes
  }

  tags     = each.value.instance_network_tags
  metadata = each.value.instance_metadata
}

resource "google_compute_instance_iam_member" "vm_iam_binding" {
  for_each      = { for b in var.vm_iam_bindings : "${b.instance_name}-${b.iam_role}-${b.member_identity}" => b }
  project       = var.gcp_project_id
  zone          = each.value.instance_zone
  instance_name = each.value.instance_name
  role          = each.value.iam_role
  member        = each.value.member_identity
  depends_on    = [google_compute_instance.vm]
}
