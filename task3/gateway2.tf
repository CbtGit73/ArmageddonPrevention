#Gateway
resource "google_compute_vpn_gateway" "gateway-2" {
  name       = "ap-to-hq"
  network    = google_compute_network.damb-ap-vpc.id
  region     = "asia-east2"
  depends_on = [google_compute_subnetwork.sub-sg-ap-cbt]
}
#>>>

#IP Birth
resource "google_compute_address" "st2" {
  name   = "st2"
  region = "asia-east2"
}
#IP Output
output "gateway2-ip" {
  value = google_compute_address.st2.address
}
#>>>

#Fowarding Rule to Link Gatway to Generated IP
resource "google_compute_forwarding_rule" "rule4" {
  name        = "rule-4"
  region      = "asia-east2"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.st2.address
  target      = google_compute_vpn_gateway.gateway-2.self_link
}
#>>>

#UPD 500 traffic Rule
resource "google_compute_forwarding_rule" "rule5-500" {
  name        = "rule-5"
  region      = "asia-east2"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.st2.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.gateway-2.self_link
}
#>>>

#UDP 4500 traffic rule
resource "google_compute_forwarding_rule" "rule6-4500" {
  name        = "rule-6"
  region      = "asia-east2"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.st2.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.gateway-2.self_link
}
#>>>

#Tunnel
resource "google_compute_vpn_tunnel" "tunnel-2" {
  name                    = "ap-to-hq-tunnel"
  target_vpn_gateway      = google_compute_vpn_gateway.gateway-2.id
  peer_ip                 = google_compute_address.st1.address
  shared_secret           = sensitive("faquettetuseifraise")
  ike_version             = 2
  local_traffic_selector  = ["192.168.0.0/24"]
  remote_traffic_selector = ["10.132.30.0/24"]
  depends_on = [
    google_compute_forwarding_rule.rule4,
    google_compute_forwarding_rule.rule5-500,
    google_compute_forwarding_rule.rule6-4500
  ]
}
#>>>

#Next Hop to Final Destination
resource "google_compute_route" "route2" {
  name                = "route2"
  network             = google_compute_network.damb-ap-vpc.id
  dest_range          = "10.132.30.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel-2.id
  depends_on          = [google_compute_vpn_tunnel.tunnel-2]
}
#>>>

#Internal Traffic Firewall rule
resource "google_compute_firewall" "allow_internal-2" {
  name    = "allow-internal-2"
  network = google_compute_network.damb-ap-vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.132.30.0/24"]
  description   = "Allow all internal traffic from peer network"
}