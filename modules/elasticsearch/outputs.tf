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
