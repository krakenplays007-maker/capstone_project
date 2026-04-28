 vms = [
  {
    instance_name             = "dev-vm-1"
    instance_machine_type     = "e2-small"
    instance_zone             = "us-central1-a"
    boot_disk_image           = "debian-cloud/debian-12"
    boot_disk_size_gb         = 20
    instance_subnetwork_name  = "dev-subnet"
    enable_external_ip        = false
    instance_network_tags     = ["ssh", "web"]
    instance_metadata         = {}
    vm_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
]
