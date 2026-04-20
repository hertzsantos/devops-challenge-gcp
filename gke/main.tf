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

#
# GKE Cluster Definition
#
# This cluster is configured as a private cluster: the nodes do not receive
# external IP addresses and communicate with the control plane over internal
# IPs only. To provide outbound internet connectivity, the cluster relies on
# Cloud NAT configured in the network module. Private clusters offer greater
# security and isolation【758611770207696†L61-L79】.
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  network  = var.network
  subnetwork = var.private_subnet

  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = 30
  }

  # Use VPC‑native clusters with IP aliasing. We reference the secondary ranges
  # created in the network module for Pod and Service CIDRs.
  ip_allocation_policy {
    cluster_secondary_range_name = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Private cluster configuration. The master IPv4 CIDR block must be a /28
  # within 172.16.0.0/28–172.16.255.0/28 that doesn’t overlap with any other
  # subnet. Adjust this value if necessary.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  # Enable Workload Identity: this maps Kubernetes service accounts to Google
  # Cloud service accounts, allowing pods to access cloud resources without
  # storing service account keys【521552609189340†L14-L26】.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Control plane release channel. Options are RAPID, REGULAR, STABLE. Use
  # REGULAR for a balance between stability and freshness.
  release_channel {
    channel = var.release_channel
  }

    master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

    resource_labels = {
      environment = var.environment
      project     = var.project_id
      managed_by  = "terraform"
  }

  enable_intranode_visibility = true

  # Permite que o cluster seja destruído e recriado quando houver mudanças significativas
  deletion_protection = false
}

# Node pool configuration. We create a single node pool with autoscaling.
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-primary-pool"
  cluster    = google_container_cluster.primary.name  
  location   = var.region

  node_count = var.initial_node_count

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    # Use the default compute service account. If you prefer a custom service
    # account for nodes, specify it here.
    service_account = null

    # Disable legacy metadata endpoints for enhanced security.
    metadata = {
      "disable-legacy-endpoints" = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # reduz tamanho da raiz e usa disco HDD (pd-standard) para não consumir a cota de SSD
    disk_size_gb = 30
    disk_type    = "pd-standard"
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
# ------------------------------------------------------------------------------
# DECISÕES DE SEGURANÇA (LAB)
#
# Os itens abaixo não foram aplicados por limitação de escopo/ambiente:
#
# - Binary Authorization → exige pipeline e política de imagens
# - RBAC com Google Groups → depende de identidade corporativa
# - Master Authorized Networks → pode causar bloqueio de acesso no ambiente
#
# Observação:
# - Secure Boot já aplicado no node pool
#
# Em produção, todos esses controles devem ser implementados.
# ------------------------------------------------------------------------------