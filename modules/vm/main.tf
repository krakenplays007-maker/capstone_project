resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
    }
  }

  network_interface {
    subnetwork = var.instance_subnetwork

    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.vm_service_account_email
    scopes = var.vm_service_account_scopes
  }

  tags     = var.instance_network_tags
  metadata = var.instance_metadata
}
