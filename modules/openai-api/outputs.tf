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