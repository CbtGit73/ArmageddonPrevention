resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.damb-am1-vpc.self_link
  peer_network = google_compute_network.damb-am2-vpc.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.damb-am2-vpc.self_link
  peer_network = google_compute_network.damb-am1-vpc.self_link
}

