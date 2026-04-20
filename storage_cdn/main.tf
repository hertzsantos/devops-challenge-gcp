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
  name          = "${var.project_id}-logs"
  location      = var.region
  force_destroy = true
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
  name          = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-static"
  location      = var.region
  force_destroy = true
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