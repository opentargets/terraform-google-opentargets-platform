// --- Web Application Module Output Information --- //
// Bucket Information --- //
output "bucket" {
  value = module.bucket_webapp
}

// Web Server details --- //
output "deployment_regions" {
  value = var.webserver_deployment_regions
}

output "map_region_to_instance_group_manager" {
  value = zipmap(
    var.webserver_deployment_regions,
    google_compute_region_instance_group_manager.regmig_webserver.*
  )
}

output "capacity_scalers" {
  value = zipmap(
    var.webserver_deployment_regions,
    google_compute_region_autoscaler.autoscaler_webserver.*
  )
}

output "webserver_port" {
  // Output the listening port for the Open Targets Platform Web Server
  value = local.webapp_webserver_port
}

output "webserver_port_name" {
  // Output the custom named port for the instance group
  value = local.webapp_webserver_port_name
}