// Open Targets Platform Infrastructure
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.55.0"
    }
  }
}

provider "google" {
  region = var.config_gcp_default_region
  project = var.config_project_id
}

// --- Elastic Search Backend --- //

module "backend_elastic_search" {
  source = "./module/elasticsearch"
  count = length(var.config_deployment_regions)

  depends_on = [ module.vpc_network ]
  module_wide_prefix_scope = "${var.config_release_name}-es-${count.index}"
  network_name = module.vpc_network.network_name
  network_self_link = module.vpc_network.network_self_link
  network_subnet_name = local.vpc_network_main_subnet_name
  network_source_ranges = [
    local.vpc_network_region_subnet_map[var.config_deployment_regions[count.index]].subnet_ip
  ]
  // Elastic Search configuration
  vm_elastic_search_version = var.config_vm_elastic_search_version
  vm_elastic_search_vcpus = var.config_vm_elastic_search_vcpus
  // Memory size in MiB
  vm_elastic_search_mem = var.config_vm_elastic_search_mem
  vm_elastic_search_image = var.config_vm_elastic_search_image
  vm_elastic_search_image_project = var.config_vm_elastic_search_image_project
  vm_elastic_search_boot_disk_size = var.config_vm_elastic_search_boot_disk_size
  deployment_region = var.config_deployment_regions[count.index]
  deployment_target_size = 1
}
