// --- API Firewall definition --- //
// Allow traffic to API --- //
resource "google_compute_firewall" "vpc_netfw_otprometheus_node" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-otprometheus-node"
  description = "Firewall rule to allow API inbound traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.otp_prometheus_port, local.otp_grafana_port, local.otp_loki_port]
  }

  target_tags = [local.fw_tag_otp_prometheus_node]

  source_ranges = ["0.0.0.0/0"]
}

// Health Checks Traffic --- //
resource "google_compute_firewall" "vpc_netfw_otprometheus_healthchecks" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-otprometheus-healthchecks"
  description = "Firewall rule to allow API Health Checks traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.otp_prometheus_port]
  }

  target_tags = [local.fw_tag_otp_prometheus_node]

  source_ranges = ["0.0.0.0/0"]
}