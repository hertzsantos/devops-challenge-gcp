variable "project_id" {
  description = "ID do projeto GCP onde a VPC será provisionada"
  type        = string
}

variable "region" {
  description = "Região em que a VPC e os sub‑recursos serão criados"
  type        = string
  default     = "southamerica-east1"
}

variable "network_name" {
  description = "Nome base da VPC"
  type        = string
  default     = "demo-network"
}

variable "public_subnet_cidr" {
  description = "CIDR da sub‑rede pública"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR da sub‑rede privada"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pods_secondary_cidr" {
  description = "CIDR do intervalo secundário para os Pods do GKE"
  type        = string
  default     = "10.1.0.0/20"
}

variable "services_secondary_cidr" {
  description = "CIDR do intervalo secundário para os serviços do GKE"
  type        = string
  default     = "10.2.0.0/24"
}

variable "pods_secondary_range_name" {
  description = "Nome do intervalo secundário para Pods (referenciado pelo GKE)"
  type        = string
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  description = "Nome do intervalo secundário para Serviços (referenciado pelo GKE)"
  type        = string
  default     = "gke-services"
}