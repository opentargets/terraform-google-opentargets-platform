// --- Prometheus Module Output Information --- //
output "deployment_regions" {
  value = var.deployment_regions
}

output "map_region_to_instance_group_manager" {
  value = zipmap(
    var.deployment_regions,
    google_compute_region_instance_group_manager.regmig_otprometheus.*
  )
}

output "prometheus_port" {
  // Output the listening port for the Open Targets Platform API
  value = local.otp_prometheus_port
}

output "prometheus_port_name" {
  // Output the custom named port for the instance group
  value = local.otp_prometheus_port_name
}

output "ilb_ip_addresses" {
  value = zipmap(
    [for ilb in google_compute_forwarding_rule.ilb_forwarding_rule : ilb.region],
    [for ilb in google_compute_forwarding_rule.ilb_forwarding_rule : ilb.ip_address]
  )
}
