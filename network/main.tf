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
## Virtual Private Cloud (VPC) and Subnets
##

# Primary VPC for the environment. We disable automatic subnet creation so that
# the Terraform configuration controls exactly which subnets exist.
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Public subnet. Instances launched here can be assigned external IP addresses.
# We enable private Google access so that resources without public IPs can still
# reach Google APIs over the private network if needed.
resource "google_compute_subnetwork" "public" {
  name          = "${var.network_name}-public"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  # Allow traffic to Google APIs over private IPs.
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Private subnet. Nodes here do not require external IPs and will rely on
# Cloud NAT for outbound internet connectivity. We define secondary ranges for
# the GKE cluster's Pods and Services IPs, which are required when using
# VPC‑native clusters.
resource "google_compute_subnetwork" "private" {
  name          = "${var.network_name}-private"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  private_ip_google_access = true

  # Define secondary IP ranges for the GKE pods and services. In recent
  # versions of the Google provider, these must be defined as nested
  # `secondary_ip_range` blocks rather than as a list of objects. Each
  # block declares a range name and the associated CIDR. These ranges
  # allow the VPC‑native GKE cluster to allocate IPs for pods and
  # services without overlapping the primary subnet range.
  secondary_ip_range {
    range_name    = var.pods_secondary_range_name
    ip_cidr_range = var.pods_secondary_cidr
  }
  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.services_secondary_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

##
## NAT and Routing
##

# Create a Cloud Router. This resource is used by Cloud NAT to manage routing
# information. It does not perform BGP in this configuration but is required
# for NAT.
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT configuration. This allows instances in the private subnet to
# initiate outbound connections to the internet without exposing individual
# node IPs. According to a comparison of GCP and AWS NAT services, Cloud NAT
# automatically scales and charges based on IP addresses and data volume【538834209207952†L106-L136】.
resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Firewall básico para permitir tráfego interno na VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr
  ]
}