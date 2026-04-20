variable "project_id" {
  description = "ID do projeto onde a conta de serviço será criada"
  type        = string
}

variable "region" {
  description = "Região do projeto (não usada diretamente)"
  type        = string
  default     = "southamerica-east1"
}

variable "bucket_name" {
  description = "Nome do bucket ao qual a conta de serviço deve ter acesso"
  type        = string
}

variable "bucket_role" {
  description = "Permissão concedida no bucket (ex: roles/storage.objectAdmin)"
  type        = string
  default     = "roles/storage.objectAdmin"
}

variable "gsa_name" {
  description = "ID (account_id) da Google service account a ser criada"
  type        = string
  default     = "admin-uploader"
}

variable "gsa_display_name" {
  description = "Nome legível da Google service account"
  type        = string
  default     = "Service account for admin uploads"
}

variable "k8s_namespace" {
  description = "Namespace Kubernetes em que o ServiceAccount será criado"
  type        = string
  default     = "default"
}

variable "k8s_service_account" {
  description = "Nome da Kubernetes ServiceAccount a ser associada com o GSA"
  type        = string
  default     = "admin-panel"
}