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

# Módulo de rede: cria a VPC, sub‑redes e NAT. As variáveis para intervalos
# secundários dos Pods e Services são fornecidas aqui para que possam ser
# customizadas no root module.
module "network" {
  source = "./network"

  project_id                    = var.project_id
  region                        = var.region
  network_name                  = var.network_name
  public_subnet_cidr            = var.public_subnet_cidr
  private_subnet_cidr           = var.private_subnet_cidr
  pods_secondary_cidr           = var.pods_secondary_cidr
  services_secondary_cidr       = var.services_secondary_cidr
  pods_secondary_range_name     = var.pods_secondary_range_name
  services_secondary_range_name = var.services_secondary_range_name
}

# Módulo de storage + CDN
module "storage_cdn" {
  source = "./storage_cdn"

  project_id  = var.project_id
  region      = var.region
  bucket_name = var.bucket_name
}

# Módulo GKE
module "gke" {
  source = "./gke"

  project_id             = var.project_id
  region                 = var.region
  cluster_name           = var.cluster_name
  network                = module.network.vpc_name
  private_subnet         = module.network.private_subnet
  pods_range_name        = module.network.pods_secondary_range_name
  services_range_name    = module.network.services_secondary_range_name
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  release_channel        = var.release_channel
  initial_node_count     = var.initial_node_count
  min_node_count         = var.min_node_count
  max_node_count         = var.max_node_count
  node_machine_type      = var.node_machine_type
}

# Módulo de Workload Identity
module "workload_identity" {
  source = "./workload_identity"

  project_id          = var.project_id
  region              = var.region
  bucket_name         = module.storage_cdn.bucket_name
  bucket_role         = var.gsa_bucket_role
  gsa_name            = var.gsa_name
  gsa_display_name    = var.gsa_display_name
  k8s_namespace       = var.k8s_namespace
  k8s_service_account = var.k8s_service_account
}