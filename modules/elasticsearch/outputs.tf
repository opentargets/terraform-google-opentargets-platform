// --- Module Output Information --- //
output "deployment_region" {
  value = var.deployment_region
}

output "network_name" {
  value = var.network_name
}

output "network_subnet_name" {
  value = var.network_subnet_name
}

output "ilb_ip_address" {
  value = google_compute_forwarding_rule.ilb_forwarding_rule.ip_address
}

// Named ports --- //
output "port_elastic_search_requests" {
  value = local.elastic_search_port_requests
}

output "port_elastic_search_requests_name" {
  value = local.elastic_search_port_requests_name
}

output "port_elastic_search_comms" {
  value = local.elastic_search_port_comms
}

output "port_elastic_search_comms_name" {
  value = local.elastic_search_port_comms_name
}
