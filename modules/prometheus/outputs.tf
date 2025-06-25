// --- Prometheus Module Output Information --- //
output "deployment_regions" {
  value = var.deployment_regions
}

output "prometheus_port" {
  // Output the listening port for the Open Targets Platform Prometheus
  value = local.otp_prometheus_port
}

output "prometheus_port_name" {
  // Output the custom named port for the instance group
  value = local.otp_prometheus_port_name
}

output "gramafa_port" {
  // Output the listening port for the Open Targets Platform Grafana
  value = local.otp_grafana_port
}