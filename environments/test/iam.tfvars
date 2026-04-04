vm_service_account_id           = "test-vm-sa"
vm_service_account_display_name = "Test VM Service Account"
vm_service_account_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/storage.objectViewer"
]

project_iam_bindings = [
  {
    iam_role        = "roles/viewer"
    member_identity = "user:test-admin@example.com"
  }
]

vm_iam_bindings = [
  {
    iam_role        = "roles/compute.instanceAdmin.v1"
    member_identity = "user:test-admin@example.com"
  }
]
