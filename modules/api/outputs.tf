// --- API Module Output Information --- //
output "deployment_regions" {
  value = var.deployment_regions
}

output "map_region_to_instance_group_manager" {
  value = zipmap(
    var.deployment_regions,
    google_compute_region_instance_group_manager.regmig_otpapi.*
  )
}

output "capacity_scalers" {
  value = zipmap(
    var.deployment_regions,
    google_compute_region_autoscaler.autoscaler_otpapi.*
  )
}

output "api_port" {
  // Output the listening port for the Open Targets Platform API
  value = local.otp_api_port
}

output "api_port_name" {
  // Output the custom named port for the instance group
  value = local.otp_api_port_name
}

output "ilb_ip_addresses" {
  value = zipmap(
    [for ilb in google_compute_forwarding_rule.ilb_forwarding_rule : ilb.region],
    [for ilb in google_compute_forwarding_rule.ilb_forwarding_rule : ilb.ip_address]
  )
}

output "glb_external_ip" {
  value = try(module.gce_lb_http[0].external_ip, null)
}
