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
## Bucket de logs
##

resource "google_storage_bucket" "logs_bucket" {
  name                        = "${var.project_id}-logs"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = null
  }
}

##
## Bucket de armazenamento para arquivos estáticos
##

resource "google_storage_bucket" "static_bucket" {
  name                        = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-static"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = null
  }

  logging {
    log_bucket        = google_storage_bucket.logs_bucket.name
    log_object_prefix = "access-logs"
  }

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
## Dados do projeto atual
##

data "google_project" "current" {
  project_id = var.project_id
}

##
## Service account do Cloud CDN / backend bucket
##

locals {
  cdn_service_account = "service-${data.google_project.current.number}@cloud-cdn-fill.iam.gserviceaccount.com"
}

##
## Permissão para o backend/CDN ler os objetos do bucket estático
##

resource "google_storage_bucket_iam_member" "cdn_object_viewer" {
  bucket = google_storage_bucket.static_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.cdn_service_account}"
}

##
## Backend bucket com Cloud CDN habilitado
##

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "static-backend-bucket"
  bucket_name = google_storage_bucket.static_bucket.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
    serve_while_stale = 86400
  }

  depends_on = [
    google_storage_bucket_iam_member.cdn_object_viewer
  ]
}