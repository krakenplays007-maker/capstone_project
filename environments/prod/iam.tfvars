vm_service_account_id           = "prod-vm-sa"
vm_service_account_display_name = "Prod VM Service Account"
vm_service_account_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/storage.objectViewer"
]

project_iam_bindings = [
  {
    iam_role        = "roles/viewer"
    member_identity = "user:prod-admin@example.com"
  }
]

vm_iam_bindings = [
  {
    instance_name   = "prod-vm-1"
    instance_zone   = "us-central1-c"
    iam_role        = "roles/compute.instanceAdmin.v1"
    member_identity = "user:prod-admin@example.com"
  }
]
