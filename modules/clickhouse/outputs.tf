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

// Named Ports --- //
output "port_clickhouse_http" {
  value = local.clickhouse_http_req_port
}

output "port_clickhouse_http_name" {
  value = local.clickhouse_http_req_port_name
}

output "port_clickhouse_cli" {
  value = local.clickhouse_cli_req_port
}

output "port_clickhouse_cli_name" {
  value = local.clickhouse_cli_req_port_name
}
