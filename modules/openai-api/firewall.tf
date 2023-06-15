// --- OpenAI API Firewall definition --- //
// Allow traffic to OpenAI API --- //
resource "google_compute_firewall" "vpc_netfw_openai_api_node" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-openai-api-node"
  description = "Firewall rule to allow OpenAI API inbound traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.openai_api_port]
  }

  target_tags = [local.fw_tag_openai_api]
  source_ranges = [
    var.network_source_ranges_map[var.deployment_regions[count.index]].source_range
  ]
}

// Health Checks Traffic --- //
resource "google_compute_firewall" "vpc_netfw_openai_api_healthchecks" {
  count = length(var.deployment_regions)

  name        = "${var.network_name}-${var.deployment_regions[count.index]}-allow-openai-api-healthchecks"
  description = "Firewall rule to allow OpenAI API Health Checks traffic"
  network     = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = [local.openai_api_port]
  }

  target_tags = [local.fw_tag_openai_api]
  source_ranges = concat(
    [var.network_source_ranges_map[var.deployment_regions[count.index]].source_range],
    var.network_sources_health_checks
  )
}