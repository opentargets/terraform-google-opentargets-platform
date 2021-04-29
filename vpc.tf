// --- Networking --- //
// Custom VPC --- //
module "vpc_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id = var.config_project_id
  network_name = local.vpc_network_name
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false

  subnets = [
    for region in var.config_deployment_regions: local.vpc_network_region_subnet_map[region]
  ]
}
