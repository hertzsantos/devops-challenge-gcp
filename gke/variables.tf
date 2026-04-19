variable "project_id" {
  description = "ID do projeto GCP utilizado pelo cluster"
  type        = string
}

variable "region" {
  description = "Região onde o cluster será criado"
  type        = string
  default     = "southamerica-east1"
}

variable "cluster_name" {
  description = "Nome do cluster GKE"
  type        = string
  default     = "admin-cluster"
}

variable "network" {
  description = "Nome da VPC onde o cluster ficará"
  type        = string
}

variable "private_subnet" {
  description = "Nome da sub‑rede privada a ser usada pelos nós"
  type        = string
}

variable "pods_range_name" {
  description = "Nome do intervalo secundário de Pods (da VPC)"
  type        = string
}

variable "services_range_name" {
  description = "Nome do intervalo secundário de Serviços (da VPC)"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR /28 para o endpoint privado do controle do cluster"
  type        = string
  default     = "172.16.0.16/28"
}

variable "release_channel" {
  description = "Canal de lançamento do GKE (RAPID, REGULAR ou STABLE)"
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
  description = "Tipo de máquina para os nós do GKE"
  type        = string
  default     = "e2-medium"
}

variable "environment" {
  description = "Ambiente do cluster (ex: dev, hml, prod)"
  type        = string
  default     = "dev"
}