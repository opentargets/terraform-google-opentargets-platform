// --- Firewall Configuration --- //
// Elastic Search Traffic --- //
// Requests
resource "google_compute_firewall" "vpc_netfw_elasticsearch_requests" {
  name = "${var.network_name}-${var.deployment_region}-allow-elasticsearch-requests"
  description = "Firewall rule for allowing Elastic Search Requests Traffic"
  network = var.network_self_link

  allow {
      protocol = "tcp"
      ports = [ local.elastic_search_port_requests ]
  }

  target_tags = [ local.fw_tag_elasticsearch_requests ]
  source_ranges = var.network_source_ranges
}

