#Gateway
resource "google_compute_vpn_gateway" "gateway-1" {
  name       = "hq-to-ap"
  network    = google_compute_network.damb-hq-vpc.id
  region     = "europe-west1"
  depends_on = [google_compute_subnetwork.sub-sg-hq-cbt2]
}
#>>>

#IP Birth
resource "google_compute_address" "st1" {
  name   = "st1"
  region = "europe-west1"
}
#IP Output
output "gateway1-ip" {
  value = google_compute_address.st1.address
}
#>>>

#Fowarding Rule to Link Gatway to Generated IP
resource "google_compute_forwarding_rule" "rule1" {
  name        = "rule-1"
  region      = "europe-west1"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.st1.address
  target      = google_compute_vpn_gateway.gateway-1.self_link
}
#>>>

#UPD 500 traffic Rule
resource "google_compute_forwarding_rule" "rule2-500" {
  name        = "rule-2"
  region      = "europe-west1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.st1.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.gateway-1.self_link
}
#>>>

#UDP 4500 traffic rule
resource "google_compute_forwarding_rule" "rule3-4500" {
  name        = "rule-3"
  region      = "europe-west1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.st1.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.gateway-1.self_link
}
#>>>

#Tunnel
resource "google_compute_vpn_tunnel" "tunnel-1" {
  name                    = "hq-to-ap-tunnel"
  target_vpn_gateway      = google_compute_vpn_gateway.gateway-1.id
  peer_ip                 = google_compute_address.st2.address
  shared_secret           = sensitive("faquettetuseifraise")
  ike_version             = 2
  local_traffic_selector  = ["10.132.30.0/24"]
  remote_traffic_selector = ["192.168.0.0/24"]
  depends_on = [
    google_compute_forwarding_rule.rule1,
    google_compute_forwarding_rule.rule2-500,
    google_compute_forwarding_rule.rule3-4500
  ]
}
#>>>

#Next Hop to Final Destination
resource "google_compute_route" "route1" {
  name                = "route1"
  network             = google_compute_network.damb-hq-vpc.id
  dest_range          = "192.168.0.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel-1.id
  depends_on          = [google_compute_vpn_tunnel.tunnel-1]
}
#>>>

#Internal Traffic Firewall rule 
resource "google_compute_firewall" "allow_internal-1" {
  name    = "allow-internal-1"
  network = google_compute_network.damb-hq-vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["192.168.0.0/24"]
  description   = "Allow all internal traffic from peer network"
}