terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

##
## Bucket de armazenamento para arquivos estáticos
##

# Cria um bucket privado no Cloud Storage para armazenar os arquivos do front‑end.
# Habilitamos o versionamento e a uniform bucket‑level access para garantir
# controle centralizado das permissões e retenção de versões antigas.
resource "google_storage_bucket" "static_bucket" {
  name          = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-static"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # A criptografia padrão utiliza as chaves gerenciadas pelo Google.
  encryption {
    default_kms_key_name = null
  }

# ------------------------------------------------------------------------------
# LOGGING (LAB)
#
# Os logs são enviados para o próprio bucket por simplicidade.
# Em produção, o ideal é utilizar um bucket separado para isolamento e segurança.
# ------------------------------------------------------------------------------

  logging {
    log_bucket        = google_storage_bucket.static_bucket.name
    log_object_prefix = "access-logs"
  }

  # Exemplo de regra de ciclo de vida para deletar objetos antigos
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

##
## Permissões de leitura para o Cloud CDN
##

# Recupera informações do projeto para construir o endereço de email da conta
# de serviço do Cloud CDN (cache‑fill service). Essa conta é responsável por
# puxar objetos do bucket privado para o cache da CDN【674853534301414†L145-L190】.
data "google_project" "current" {
  project_id = var.project_id
}

locals {
  cdn_service_account = "service-${data.google_project.current.number}@cloud-cdn-fill.iam.gserviceaccount.com"
}

#resource "google_storage_bucket_iam_member" "cdn_object_viewer" {
#  bucket = google_storage_bucket.static_bucket.name
#  role   = "roles/storage.objectViewer"
#  member = "serviceAccount:${local.cdn_service_account}"
#}

##
## Backend bucket para Cloud CDN
##

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "${var.project_id}-backend-bucket"
  bucket_name = google_storage_bucket.static_bucket.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600    # 1 hora
    max_ttl           = 86400   # 24 horas
    serve_while_stale = 86400   # 24 horas
  }
}