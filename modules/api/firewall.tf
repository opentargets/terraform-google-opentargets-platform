// --- API Firewall definition --- //
// Allow traffic to API --- //
resource "google_compute_firewall" "vpc_netfw_otpapi_node" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-otpapi-node"
  description = "Firewall rule to allow API inbound traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.otp_api_port, local.otp_api_node_exporter_port]
  }

  target_tags = [local.fw_tag_otp_api_node]
  source_ranges = [
    var.network_source_ranges_map[var.deployment_regions[count.index]].source_range
  ]
}

// Health Checks Traffic --- //
resource "google_compute_firewall" "vpc_netfw_otpapi_healthchecks" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-otpapi-healthchecks"
  description = "Firewall rule to allow API Health Checks traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.otp_api_port]
  }

  target_tags = [local.fw_tag_otp_api_node]
  source_ranges = concat(
    [var.network_source_ranges_map[var.deployment_regions[count.index]].source_range],
    var.network_sources_health_checks
  )
}