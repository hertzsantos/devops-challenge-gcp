output "network_vpc_name" {
  description = "Nome da VPC"
  value       = module.network.vpc_name
}

output "static_bucket_name" {
  description = "Nome do bucket de assets"
  value       = module.storage_cdn.bucket_name
}

output "gke_cluster_name" {
  description = "Nome do cluster GKE"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint da API do cluster"
  value       = module.gke.cluster_endpoint
}

output "workload_gsa_email" {
  description = "Email da Google service account para Workload Identity"
  value       = module.workload_identity.gsa_email
}