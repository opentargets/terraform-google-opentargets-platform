// --- Firewall Rules --- //
// Common / root rules deployment wide

// Allow ICMP traffic --- //
resource "google_compute_firewall" "vpc_netfw_allow_icmp" {
  name        = "${module.vpc_network.network_name}-allow-icmp"
  description = "VPC-wide firewall baseline configuration to allow ICMP"
  network     = module.vpc_network.network_self_link
  depends_on  = [module.vpc_network]

  allow {
    protocol = "icmp"
  }
  
  source_ranges = [
    "0.0.0.0/0"
  ]
}

// Allow HTTP traffic to tagged nodes --- //
resource "google_compute_firewall" "vpc_netfw_allow_http" {
  name        = "${module.vpc_network.network_name}-allow-http"
  description = "VPC-wide firewall configuration to allow HTTP on VMs tagged accrodingly"
  network     = module.vpc_network.network_self_link
  depends_on  = [module.vpc_network]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  target_tags = [local.fw_tag_http]
  source_ranges = [
    "0.0.0.0/0"
  ]
}

// Allow HTTPS traffic to tagged nodes --- //
resource "google_compute_firewall" "vpc_netfw_allow_https" {
  name        = "${module.vpc_network.network_name}-allow-https"
  description = "VPC-wide firewall configuration to allow HTTPS on VMs tagged accrodingly"
  network     = module.vpc_network.network_self_link
  depends_on  = [module.vpc_network]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags = [local.fw_tag_https]
  source_ranges = [
    "0.0.0.0/0"
  ]
}

// Allow SSH traffic to tagged nodes --- //
resource "google_compute_firewall" "vpc_netfw_allow_ssh" {
  name        = "${module.vpc_network.network_name}-allow-ssh"
  description = "VPC-wide firewall configuration to allow SSH on VMs tagged accrodingly"
  network     = module.vpc_network.network_self_link
  depends_on  = [module.vpc_network]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = [local.fw_tag_ssh]
  source_ranges = [
    "0.0.0.0/0"
  ]
}
