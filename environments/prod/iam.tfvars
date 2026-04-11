vm_service_account_id           = "prod-vm-sa"
vm_service_account_display_name = "Prod VM Service Account"
vm_service_account_roles = [
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/storage.objectViewer"
]

project_iam_bindings = []

vm_iam_bindings = []
