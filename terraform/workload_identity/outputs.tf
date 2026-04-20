output "gsa_email" {
  description = "Endereço de email da Google service account criada"
  value       = google_service_account.gsa.email
}