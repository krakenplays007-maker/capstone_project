output "vm_service_account_email" {
  description = "Email of the created VM service account"
  value       = google_service_account.vm_service_account.email
}

output "vm_service_account_id" {
  description = "Unique ID of the VM service account"
  value       = google_service_account.vm_service_account.unique_id
}
