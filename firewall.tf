// --- Firewall Rules --- //
// Common / root rules deployment wide

// Allow ICMP traffic --- //
resource "google_compute_firewall" "vpc_netfw_allow_icmp" {
  name = "${module.vpc_network.network_name}-allow-icmp"
  description = "VPC-wide firewall baseline configuration to allow ICMP"
  network = module.vpc_network.network_self_link
  depends_on = [ module.vpc_network ]

  allow {
      protocol = "icmp"
  }
}

