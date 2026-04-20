variable "project_id" {
  description = "ID do projeto GCP onde o bucket e o backend serão criados"
  type        = string
}

variable "region" {
  description = "Região para a localização do bucket"
  type        = string
  default     = "southamerica-east1"
}

variable "bucket_name" {
  description = "Nome opcional do bucket. Se vazio, será derivado do project_id"
  type        = string
  default     = ""
}