output "vpc_name" {
  description = "Nome da VPC criada"
  value       = google_compute_network.vpc.name
}

output "public_subnet" {
  description = "Nome da sub‑rede pública"
  value       = google_compute_subnetwork.public.name
}

output "private_subnet" {
  description = "Nome da sub‑rede privada"
  value       = google_compute_subnetwork.private.name
}

output "region" {
  description = "Região da VPC"
  value       = var.region
}

output "pods_secondary_range_name" {
  description = "Nome do intervalo secundário de Pods"
  value       = var.pods_secondary_range_name
}

output "services_secondary_range_name" {
  description = "Nome do intervalo secundário de Serviços"
  value       = var.services_secondary_range_name
}