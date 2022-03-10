variable "project" {
  default = "sojern"
}

variable "region" {
  default = "us-east1"
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  zone        = "${var.region}-b"
}

resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc"
  project                 = var.project
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project}-subnet"
  region        = var.region
  project       = var.project
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}


resource "google_container_cluster" "gke" {
  name            = "${var.project}-gke-cluster"
  location        = var.region
  node_locations  = ["${var.region}-b"]
  project         = var.project
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool-1"
  location   = var.region
  project    = var.project
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-small"
    taint = [
        {
        effect = "NO_SCHEDULE"
        key    = "preemptible"
        value  = "false"
        }
    ]
  }
}

resource "google_container_node_pool" "primary_non_preemptible_nodes" {
  name       = "node-pool-2"
  location   = var.region
  project    = var.project
  cluster    = google_container_cluster.gke.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-small"
  }
}