# Project-level IAM bindings
resource "google_project_iam_member" "project_iam_binding" {
  for_each = {
    for binding in var.project_iam_bindings :
    "${binding.iam_role}-${binding.member_identity}" => binding
  }

  project = var.gcp_project_id
  role    = each.value.iam_role
  member  = each.value.member_identity
}

# VM-level IAM bindings (instance-level resource policy)
resource "google_compute_instance_iam_member" "vm_iam_binding" {
  for_each = {
    for binding in var.vm_iam_bindings :
    "${binding.iam_role}-${binding.member_identity}" => binding
  }

  project       = var.gcp_project_id
  zone          = var.instance_zone
  instance_name = var.instance_name
  role          = each.value.iam_role
  member        = each.value.member_identity
}

# Service account for the VM
resource "google_service_account" "vm_service_account" {
  account_id   = var.vm_service_account_id
  display_name = var.vm_service_account_display_name
  project      = var.gcp_project_id
}

# Attach service account roles at project level
resource "google_project_iam_member" "vm_service_account_roles" {
  for_each = toset(var.vm_service_account_roles)

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}
