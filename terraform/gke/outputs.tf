output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint (URL) do servidor de API do cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA base64 do cluster, necessário para gerar kubeconfig"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}