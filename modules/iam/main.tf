resource "google_project_iam_member" "project_iam_binding" {
  for_each = { for b in var.project_iam_bindings : "${b.iam_role}-${b.member_identity}" => b }
  project  = var.gcp_project_id
  role     = each.value.iam_role
  member   = each.value.member_identity
}

resource "google_compute_instance_iam_member" "vm_iam_binding" {
  for_each      = { for b in var.vm_iam_bindings : "${b.instance_name}-${b.iam_role}-${b.member_identity}" => b }
  project       = var.gcp_project_id
  zone          = each.value.instance_zone
  instance_name = each.value.instance_name
  role          = each.value.iam_role
  member        = each.value.member_identity
}

resource "google_service_account" "vm_service_account" {
  account_id   = var.vm_service_account_id
  display_name = var.vm_service_account_display_name
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "vm_service_account_roles" {
  for_each = toset(var.vm_service_account_roles)
  project  = var.gcp_project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.vm_service_account.email}"
}
