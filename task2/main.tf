terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
  region      = "us-central1"
  project     = "hella-first-project"
  zone        = "us-central1-a"
  credentials = "hella-first-project-872924c19155.json"
}

resource "google_compute_network" "dont-armageddon-me-bro-vpc" {
  name                    = "dont-armageddon-me-bro-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg-cbt" {
  name                     = "subby-sg-cbt"
  network                  = google_compute_network.dont-armageddon-me-bro-vpc.id
  ip_cidr_range            = "10.0.0.0/24"
  region                   = "asia-northeast2"
  private_ip_google_access = false

}

resource "google_compute_firewall" "vpc-firewall" {
  name    = "allow-icmp"
  network = google_compute_network.dont-armageddon-me-bro-vpc.id
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "22"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["73.9.232.117"]
  priority      = 90
}

resource "google_compute_instance" "dont-armageddon-me-bro-instance" {
  depends_on   = [google_compute_firewall.vpc-firewall]
  name         = "dont-armageddon-me-bro-instance"
  machine_type = "e2-medium"
  zone         = "asia-northeast2-a"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    auto_delete = false
  }

  metadata_startup_script = <<-EO
    #!/bin/bash
    apt-get update
    apt-get install apache2 -y
    systemctl start apache2
    systemctl enable apache2
    # GCP Metadata server base URL and header
METADATA_URL="http://metadata.google.internal/computeMetadata/v1"
METADATA_FLAVOR_HEADER="Metadata-Flavor: Google"

# Create a simple HTML page and include instance details
cat <<EOF > /var/www/html/index.html
<html><body>
<h2>Don't Armageddon Me Bro!</h2>
<iframe src="https://giphy.com/embed/nR4L10XlJcSeQ" width="480" height="412" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/no-cat-nR4L10XlJcSeQ">via GIPHY</a></p>
<h3>A Plea To The Gentle Spirit Buried Inside Of Theo</h3>
</body></html>
    EO


  network_interface {
    network    = google_compute_network.dont-armageddon-me-bro-vpc.id
    subnetwork = google_compute_subnetwork.sub-sg-cbt.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "terraform-christo@hella-first-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]

  }
}

resource "google_compute_firewall" "instance_http_firewall" {
  name    = "allow-http"
  network = google_compute_network.dont-armageddon-me-bro-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "public_ip_address" {
  value = google_compute_instance.dont-armageddon-me-bro-instance.network_interface.0.access_config.0.nat_ip
}

output "vpc" {
  value = google_compute_network.dont-armageddon-me-bro-vpc.name
}

output "vm_subnet" {
  value = google_compute_subnetwork.sub-sg-cbt.name
}

output "internal_vm_ip" {
  value = google_compute_instance.dont-armageddon-me-bro-instance.network_interface.0.network_ip
}
