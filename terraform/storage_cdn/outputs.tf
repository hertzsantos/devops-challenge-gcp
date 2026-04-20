output "bucket_name" {
  description = "Nome do bucket de armazenamento para assets"
  value       = google_storage_bucket.static_bucket.name
}

output "backend_bucket_name" {
  description = "Nome do backend bucket utilizado pelo Cloud CDN"
  value       = google_compute_backend_bucket.cdn_backend.name
}