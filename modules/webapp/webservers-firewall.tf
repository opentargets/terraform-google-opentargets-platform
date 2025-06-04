// --- Web Server Firewall definition --- //
// Allow traffic to Web Server --- //
resource "google_compute_firewall" "vpc_netfw_webserver_node" {
  count = length(var.webserver_deployment_regions)

  name        = "${var.network_name}-${var.webserver_deployment_regions[count.index]}-allow-webserver-node"
  description = "Firewall rule to allow Web Server inbound traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.webapp_webserver_port, local.node_exporter_webserver_port]
  }

  target_tags = [local.fw_tag_webserver_node]
  source_ranges = [
    var.network_source_ranges_map[var.webserver_deployment_regions[count.index]].source_range
  ]
}

// Health Checks Traffic --- //
resource "google_compute_firewall" "vpc_netfw_webserver_healthchecks" {
  count = length(var.webserver_deployment_regions)

  name        = "${var.network_name}-${var.webserver_deployment_regions[count.index]}-allow-webserver-healthchecks"
  description = "Firewall rule to allow Web Server Health Checks traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.webapp_webserver_port]
  }

  target_tags = [local.fw_tag_webserver_node]
  source_ranges = concat(
    [var.network_source_ranges_map[var.webserver_deployment_regions[count.index]].source_range],
    var.network_sources_health_checks
  )
}