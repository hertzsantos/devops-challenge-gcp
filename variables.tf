variable "project_id" {
  description = "ID do projeto GCP onde todos os recursos serão criados"
  type        = string
}

variable "region" {
  description = "Região padrão para recursos"
  type        = string
  default     = "southamerica-east1"
}

variable "network_name" {
  description = "Nome base para a VPC"
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
  description = "CIDR do intervalo secundário para Pods"
  type        = string
  default     = "10.0.2.0/24"
}

variable "services_secondary_cidr" {
  description = "CIDR do intervalo secundário para Services"
  type        = string
  default     = "10.0.3.0/24"
}

variable "pods_secondary_range_name" {
  description = "Nome do intervalo secundário de Pods"
  type        = string
  default     = "gke-pods"
}

variable "services_secondary_range_name" {
  description = "Nome do intervalo secundário de Services"
  type        = string
  default     = "gke-services"
}

variable "bucket_name" {
  description = "Nome opcional do bucket para armazenar os assets"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Nome do cluster Kubernetes"
  type        = string
  default     = "admin-cluster"
}

variable "master_ipv4_cidr_block" {
  description = "Bloco CIDR /28 para o endpoint da API do cluster"
  type        = string
  default     = "172.16.0.16/28"
}

variable "release_channel" {
  description = "Canal de lançamento do GKE"
  type        = string
  default     = "REGULAR"
}

variable "initial_node_count" {
  description = "Número inicial de nós na node pool"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Número mínimo de nós para autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nós para autoscaling"
  type        = number
  default     = 3
}

variable "node_machine_type" {
  description = "Tipo de máquina para os nós GKE"
  type        = string
  default     = "e2-medium"
}

variable "gsa_bucket_role" {
  description = "Papel IAM atribuído ao GSA para interagir com o bucket (e.g., roles/storage.objectAdmin)"
  type        = string
  default     = "roles/storage.objectAdmin"
}

variable "gsa_name" {
  description = "ID da Google service account usada pelo Workload Identity"
  type        = string
  default     = "admin-uploader"
}

variable "gsa_display_name" {
  description = "Descrição da Google service account"
  type        = string
  default     = "Service account for admin uploads"
}

variable "k8s_namespace" {
  description = "Namespace do Kubernetes ServiceAccount"
  type        = string
  default     = "admin"
}

variable "k8s_service_account" {
  description = "Nome da Kubernetes ServiceAccount que usará Workload Identity"
  type        = string
  default     = "admin-panel"
}