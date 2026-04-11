vm_service_account_id           = "dev-vm-sa"
vm_service_account_display_name = "Dev VM Service Account"
vm_service_account_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter"
]

project_iam_bindings = [
  {
    iam_role        = "roles/editor"
    member_identity = "user:dev-admin@example.com"
  }
]

vm_iam_bindings = [
  {
    instance_name   = "dev-vm-1"
    instance_zone   = "us-central1-a"
    iam_role        = "roles/compute.instanceAdmin.v1"
    member_identity = "user:dev-admin@example.com"
  }
]
