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
## Service Account for Workload Identity
##

# This Google service account will be impersonated by a Kubernetes service
# account running in GKE. Grant it the minimal roles required to upload
# objects into the static bucket.
resource "google_service_account" "gsa" {
  account_id   = var.gsa_name
  display_name = var.gsa_display_name
}

# Grant storage permissions on the target bucket. The role "roles/storage.objectAdmin"
# allows listing, creating and deleting objects in the bucket. Adjust as
# necessary (for upload‑only, use roles/storage.objectCreator).
resource "google_storage_bucket_iam_member" "gsa_storage_admin" {
  bucket = var.bucket_name
  role   = var.bucket_role
  member = "serviceAccount:${google_service_account.gsa.email}"
}

# Allow the Kubernetes service account to impersonate the Google service account
# via Workload Identity. Without this binding, the KSA cannot assume the GSA’s
# identity【521552609189340†L14-L26】.
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
}