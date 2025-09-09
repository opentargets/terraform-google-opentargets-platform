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

output "prometheus_config" {
  value = local.prometheus_config_file
}
output "prometheus_zones" {
  value = local.zones
}

output "log_bucket_url" {
  value = google_storage_bucket.log-storage.url
}

output "server_names" {
  description = "Name of the observabilty across regions"
  value = google_compute_instance.default[*].name
}