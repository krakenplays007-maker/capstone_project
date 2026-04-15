vms = [
#   {
#     instance_name             = "dev-vm-1"
#     instance_machine_type     = "e2-small"
#     instance_zone             = "us-central1-a"
#     boot_disk_image           = "debian-cloud/debian-12"
#     boot_disk_size_gb         = 20
#     instance_subnetwork_name  = "dev-subnet"
#     enable_external_ip        = false
#     instance_network_tags     = ["ssh", "web"]
#     instance_metadata         = {}
#     vm_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#   }

{
    instance_name             = "win-server-2022"
    instance_machine_type     = "e2-medium" # Windows requires at least 2GB RAM; e2-medium is recommended
    instance_zone             = "us-central1-a"
    boot_disk_image           = "windows-cloud/windows-2022"
    boot_disk_size_gb         = 50 # Windows requires a minimum of 50GB
    instance_subnetwork_name  = "dev-subnet"
    enable_external_ip        = false
    instance_network_tags     = ["rdp"] # Changed 'ssh/web' to 'rdp' for Windows remote desktop
    instance_metadata         = {}
    vm_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
]
