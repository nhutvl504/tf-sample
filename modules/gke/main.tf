


resource "google_compute_subnetwork" "custom" {
  name          = "gke-custom1"
  ip_cidr_range = var.secondary_ip_range
  region        = var.region
  network       = var.network_name
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }
}


resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  network                  = var.network_name
  subnetwork               = google_compute_subnetwork.custom.id
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = google_compute_subnetwork.custom.secondary_ip_range.0.range_name

  }
  enable_multi_networking = true
  datapath_provider       = "ADVANCED_DATAPATH"
  depends_on              = [google_compute_subnetwork.custom]
  
  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    disk_size_gb = var.disk_size_gb
    disk_type = var.disk_type
  }
}

resource "google_container_node_pool" "primary_nodes_1" {
  name       = "nodepool-1"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  node_count = var.node_pool_1_count

  # network_config {

  #   additional_node_network_configs {
  #     # network = google_compute_network.vpc.id
  #     subnetwork = var.private_subnet_1
  #   }

  # }

  depends_on = [google_container_cluster.primary]
}

# resource "google_container_node_pool" "primary_nodes_2" {
#   name       = "nodepool-2"
#   cluster    = google_container_cluster.primary.name
#   location   = var.region
#   node_count = var.node_pool_2_count

#   # network_config {

#   #   additional_node_network_configs {
#   #     # network = google_compute_network.vpc.id
#   #     subnetwork = var.private_subnet_2
#   #   }

#   # }


#   node_config {
#     machine_type = var.machine_type
#     disk_size_gb = var.disk_size_gb
#     disk_type = var.disk_type
#     oauth_scopes = [ter
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }

#   depends_on = [google_container_cluster.primary]
# }
