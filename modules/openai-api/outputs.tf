// --- OpenAI API Module Output Information --- //
output "deployment_regions" {
  value = var.deployment_regions
}

output "map_region_to_instance_group_manager" {
  value = zipmap(
    var.deployment_regions,
    google_compute_region_instance_group_manager.remig_openai_api.*
  )
}

output "openai_api_port" {
  // Output the listening port for the Open Targets Platform OpenAI API
  value = local.openai_api_port
}

output "openai_api_port_name" {
  // Output the custom named port for the instance group
  value = local.openai_api_port_name
}