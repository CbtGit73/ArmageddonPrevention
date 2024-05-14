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

resource "google_compute_network" "damb-hq-vpc" {
  name                    = "damb-hq-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg-hq-cbt1" {
  name                     = "subby-hq-cbt1"
  network                  = google_compute_network.damb-hq-vpc.id
  ip_cidr_range            = "10.0.0.0/24"
  region                   = "europe-west4"
  private_ip_google_access = false

}

resource "google_compute_subnetwork" "sub-sg-hq-cbt2" {
  name                     = "subby-hq-cbt1"
  network                  = google_compute_network.damb-hq-vpc.id
  ip_cidr_range            = "10.132.30.0/24"
  region                   = "europe-west1"
  private_ip_google_access = false

}

resource "google_compute_firewall" "damb-hq-vpc-firewall" {
  name    = "allow-rdp"
  network = google_compute_network.damb-hq-vpc.id
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["73.9.232.117"]
  priority      = 90
}

resource "google_compute_instance" "damb-hq-instance" {
  depends_on   = [google_compute_firewall.damb-hq-vpc-firewall]
  name         = "dont-armageddon-me-bro-instance2"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

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
    network    = google_compute_network.damb-hq-vpc.id
    subnetwork = google_compute_subnetwork.sub-sg-hq-cbt2.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "terraform-christo@hella-first-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]

  }
}

resource "google_compute_network" "damb-am1-vpc" {
  name                    = "damb-am1-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg-am1-cbt" {
  name                     = "subby-am1-cbt"
  network                  = google_compute_network.damb-am1-vpc.id
  ip_cidr_range            = "172.16.0.0/24"
  region                   = "us-west4"
  private_ip_google_access = false

}

resource "google_compute_firewall" "damb-am1-vpc-firewall" {
  name    = "allow-http1"
  network = google_compute_network.damb-am1-vpc.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["73.9.232.117"]
  priority      = 90
}

resource "google_compute_instance" "damb-am1-instance" {
  depends_on   = [google_compute_firewall.damb-am1-vpc-firewall]
  name         = "damb-am1-instance"
  machine_type = "n2d-standard-2"
  zone         = "us-west4-a"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 100
    }
    auto_delete = false
  }

  network_interface {
    network    = google_compute_network.damb-am1-vpc.id
    subnetwork = google_compute_subnetwork.sub-sg-am1-cbt.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "terraform-christo@hella-first-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]

  }
}

resource "google_compute_network" "damb-am2-vpc" {
  name                    = "damb-am2-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg-am2-cbt" {
  name                     = "subby-am2-cbt"
  network                  = google_compute_network.damb-am2-vpc.id
  ip_cidr_range            = "172.16.1.0/24"
  region                   = "southamerica-east1"
  private_ip_google_access = false
}

resource "google_compute_firewall" "damb-am2-vpc-firewall" {
  name    = "allow-http2"
  network = google_compute_network.damb-am2-vpc.id
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["73.9.232.117"]
  priority      = 90
}

resource "google_compute_instance" "damb-am2-instance" {
  depends_on   = [google_compute_firewall.damb-am2-vpc-firewall]
  name         = "damb-am2-instance"
  machine_type = "n2d-standard-2"
  zone         = "southamerica-east1-a"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 100
    }
    auto_delete = false
  }

  network_interface {
    network    = google_compute_network.damb-am2-vpc.id
    subnetwork = google_compute_subnetwork.sub-sg-am2-cbt.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "terraform-christo@hella-first-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]

  }
}

resource "google_compute_network" "damb-ap-vpc" {
  name                    = "damb-ap-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg-ap-cbt" {
  name                     = "subby-ap-cbt"
  network                  = google_compute_network.damb-ap-vpc.id
  ip_cidr_range            = "192.168.0.0/24"
  region                   = "asia-east2"
  private_ip_google_access = false

}

resource "google_compute_firewall" "damb-ap-vpc-firewall" {
  name    = "allow-rdp2"
  network = google_compute_network.damb-ap-vpc.id
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["73.9.232.117"]
  priority      = 90
}

resource "google_compute_instance" "damb-ap-instance" {
  depends_on   = [google_compute_firewall.damb-ap-vpc-firewall]
  name         = "damb-ap-instance"
  machine_type = "n2d-standard-2"
  zone         = "asia-east2-a"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size  = 100
    }
    auto_delete = false
  }

  network_interface {
    network    = google_compute_network.damb-ap-vpc.id
    subnetwork = google_compute_subnetwork.sub-sg-ap-cbt.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = "terraform-christo@hella-first-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]

  }
}


