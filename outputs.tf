// Outputs from this deployment
output "network_region_subnet_mapping" {
   value = local.vpc_network_region_subnet_map
}

output "elastic_search_deployments" {
  value = zipmap(
    var.config_deployment_regions,
    module.backend_elastic_search.*
  )
}

output "clickhouse_deployments" {
  value = zipmap(
    var.config_deployment_regions,
    module.backend_clickhouse.*
  )
}

output "api_deployments" {
  value = module.backend_api
}

output "webapp_deployment" {
  value = module.web_app
}

output "debug_glb_platform" {
  value = module.glb_platform
}

output "dns_records" {
  value = concat(
    [ google_dns_record_set.dns_a_api_glb ],
    google_dns_record_set.dns_a_webapp_glb
  )
}

// --- Development Mode output information --- //
output "inspection_vms" {
  value = zipmap(
    google_compute_instance.inspection_vm.*.region,
    google_compute_instance.inspection_vm.*
  )
}