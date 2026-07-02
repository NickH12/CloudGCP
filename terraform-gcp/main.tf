terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "project-55192352-4802-4484-be3"  # <--- CONFIRM THIS IS YOUR PROJECT ID
  region  = "me-west1"
  zone    = "me-west1-a"
}

# 1. The Network (VPC)
resource "google_compute_network" "vpc_network" {
  name = "k3s-network"
  auto_create_subnetworks = "true"
}

# 2. The Firewall (Security Rules)
resource "google_compute_firewall" "allow_traffic" {
  name    = "allow-k3s-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "6443"] # SSH, HTTP, HTTPS, K8s API
  }

  source_ranges = ["0.0.0.0/0"] # Allow from anywhere (For learning purposes)
}

# 3. The Server (VM)
resource "google_compute_instance" "k3s_server" {
  name         = "k3s-server"
  machine_type = "e2-medium" # 2 vCPUs, 4GB RAM (Good balance for credits)

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # This grants a Public IP
    }
  }

  # 4. The Magic: Install Kubernetes automatically on boot!
  metadata_startup_script = <<-EOT
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -
    chmod 644 /etc/rancher/k3s/k3s.yaml
  EOT
}

# 5. Output the Public IP (So we know where to connect)
output "server_ip" {
  value = google_compute_instance.k3s_server.network_interface.0.access_config.0.nat_ip
}
