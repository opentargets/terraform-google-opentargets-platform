// --- Module Firewall Configuration --- //
// Clickhouse Firewall Rules --- //
resource "google_compute_firewall" "vpc_netfw_clickhouse_node" {
  name        = "${var.network_name}-${var.deployment_region}-allow-clickhouse-node"
  description = "Firewall rule for allowing Clickhouse Requests Traffic (HTTP and CLI)"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.clickhouse_http_req_port, local.clickhouse_cli_req_port]
  }

  target_tags   = [local.fw_tag_clickhouse_node]
  source_ranges = var.network_source_ranges
}

// Health Checks Traffic --- //
resource "google_compute_firewall" "vpc_netfw_clickhouse_healthchecks" {
  name        = "${var.network_name}-${var.deployment_region}-allow-clickhouse-healthchecks"
  description = "Firewall rule for allowing Clickhouse nodes Health Checks"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.clickhouse_http_req_port]
  }

  target_tags   = [local.fw_tag_clickhouse_node]
  source_ranges = concat(var.network_source_ranges, var.network_sources_health_checks)
}