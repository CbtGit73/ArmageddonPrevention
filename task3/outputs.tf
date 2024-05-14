output "hq" {
  value = google_compute_network.damb-hq-vpc.name
}

output "hq_s1" {
  value = google_compute_subnetwork.sub-sg-hq-cbt1.name
}
output "hq_s1_range" {
  value = google_compute_subnetwork.sub-sg-hq-cbt1.ip_cidr_range
}
output "hq_s1_region" {
  value = google_compute_subnetwork.sub-sg-hq-cbt1.region
}

output "hq_s2" {
  value = google_compute_subnetwork.sub-sg-hq-cbt2.name
}
output "hq_s2_range" {
  value = google_compute_subnetwork.sub-sg-hq-cbt2.ip_cidr_range
}
output "hq_s2_region" {
  value = google_compute_subnetwork.sub-sg-hq-cbt2.region
}

output "am1" {
  value = google_compute_network.damb-am1-vpc.name
}

output "am1_s1" {
  value = google_compute_subnetwork.sub-sg-am1-cbt.name
}
output "am1_s1_range" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.ip_cidr_range
}
output "am1_s1_region" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.region
}

output "am2" {
  value = google_compute_network.damb-am2-vpc.name
}

output "am2_s2" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.name
}
output "am2_s2_range" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.ip_cidr_range
}
output "am2_s2_region" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.region
}

output "ap" {
  value = google_compute_network.damb-am2-vpc.name
}

output "n3_s1" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.name
}
output "n3_s1_range" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.ip_cidr_range
}
output "n3_s1_region" {
  value = google_compute_subnetwork.sub-sg-am2-cbt.region
}

