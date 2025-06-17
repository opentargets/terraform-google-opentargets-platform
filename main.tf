// Open Targets Platform Infrastructure
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.12.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.12.0"
    }
  }
}

provider "google" {
  region  = var.config_gcp_default_region
  project = var.config_project_id
}

provider "google-beta" {
  region  = var.config_gcp_default_region
  project = var.config_project_id
}

// --- Default Network Tier --- //
resource "google_compute_project_default_network_tier" "default_network_tier" {
  network_tier = "PREMIUM"
  project      = var.config_project_id
}

// --- Elastic Search Backend --- //
module "backend_elastic_search" {
  source     = "./modules/elasticsearch"
  project_id = var.config_project_id

  count = length(var.config_deployment_regions)

  depends_on               = [module.vpc_network]
  module_wide_prefix_scope = "${local.module_wide_prefix_es}-${count.index}"
  network_name             = module.vpc_network.network_name
  network_self_link        = module.vpc_network.network_self_link
  network_subnet_name      = local.vpc_network_main_subnet_name
  network_source_ranges = [
    local.vpc_network_region_subnet_map[var.config_deployment_regions[count.index]].subnet_ip
  ]
  // Elastic Search configuration
  vm_elastic_search_version = var.config_vm_elastic_search_version
  vm_elastic_search_vcpus   = var.config_vm_elastic_search_vcpus
  // Memory size in MiB
  vm_elastic_search_mem                          = var.config_vm_elastic_search_mem
  vm_elastic_search_image                        = var.config_vm_elastic_search_image
  vm_elastic_search_image_project                = var.config_vm_elastic_search_image_project
  vm_elastic_search_boot_disk_size               = var.config_vm_elastic_search_boot_disk_size
  vm_elastic_search_data_volume_snapshot         = var.config_vm_elastic_search_data_volume_snapshot
  vm_elastic_search_data_volume_snapshot_project = var.config_vm_elastic_search_data_volume_snapshot_project
  vm_flag_preemptible                            = var.config_vm_elasticsearch_flag_preemptible
  // Additional firewall tags if development mode is 'ON'
  vm_firewall_tags       = local.dev_mode_fw_tags
  deployment_region      = var.config_deployment_regions[count.index]
  deployment_target_size = 1
}

// --- Clickhouse Backend --- //
module "backend_clickhouse" {
  source     = "./modules/clickhouse"
  project_id = var.config_project_id

  count = length(var.config_deployment_regions)

  depends_on               = [module.vpc_network]
  module_wide_prefix_scope = "${local.module_wide_prefix_ch}-${count.index}"
  network_name             = module.vpc_network.network_name
  network_self_link        = module.vpc_network.network_self_link
  network_subnet_name      = local.vpc_network_main_subnet_name
  network_source_ranges = [
    local.vpc_network_region_subnet_map[var.config_deployment_regions[count.index]].subnet_ip
  ]
  vm_clickhouse_vcpus                        = var.config_vm_clickhouse_vcpus
  vm_clickhouse_mem                          = var.config_vm_clickhouse_mem
  vm_clickhouse_image                        = var.config_vm_clickhouse_image
  vm_clickhouse_image_project                = var.config_vm_clickhouse_image_project
  vm_clickhouse_boot_disk_size               = var.config_vm_clickhouse_boot_disk_size
  vm_clickhouse_data_volume_snapshot         = var.config_vm_clickhouse_data_volume_snapshot
  vm_clickhouse_data_volume_snapshot_project = var.config_vm_clickhouse_data_volume_snapshot_project
  vm_clickhouse_docker_image                 = var.config_vm_clickhouse_docker_image
  vm_clickhouse_docker_image_version         = var.config_vm_clickhouse_docker_image_version
  vm_flag_preemptible                        = var.config_vm_clickhouse_flag_preemptible
  // Additional firewall tags if development mode is 'ON'
  vm_firewall_tags       = local.dev_mode_fw_tags
  deployment_region      = var.config_deployment_regions[count.index]
  deployment_target_size = 1
}

// --- OpenAI API --- //

module "openai_api" {
  source                   = "./modules/openai-api"
  project_id               = var.config_project_id
  depends_on               = [module.vpc_network]
  deployment_regions       = var.config_deployment_regions
  module_wide_prefix_scope = local.module_wide_prefix_ai
  network_name             = module.vpc_network.network_name
  network_self_link        = module.vpc_network.network_self_link
  network_subnet_name      = local.vpc_network_main_subnet_name
  network_source_ranges_map = zipmap(
    var.config_deployment_regions,
    [
      for region in var.config_deployment_regions : {
        source_range = local.vpc_network_region_subnet_map[region].subnet_ip
      }
    ]
  )
  // VM tags
  vm_tags = concat(
    [local.tag_glb_target_node],
    local.dev_mode_fw_tags
  )
  // Docker
  openai_api_docker_image_version = var.config_openai_api_docker_image_version
  // Machine persona
  vm_flag_preemptible = var.config_vm_api_flag_preemptible
  // OpenAI
  openai_token = google_secret_manager_secret.openai_api_token.name
}

// --- API --- //
module "backend_api" {
  source     = "./modules/api"
  project_id = var.config_project_id
  depends_on = [
    module.vpc_network,
    module.backend_elastic_search,
    module.backend_clickhouse
  ]
  module_wide_prefix_scope = local.module_wide_prefix_api
  network_name             = module.vpc_network.network_name
  network_self_link        = module.vpc_network.network_self_link
  network_subnet_name      = local.vpc_network_main_subnet_name
  network_source_ranges_map = zipmap(
    var.config_deployment_regions,
    [
      for region in var.config_deployment_regions : {
        source_range = local.vpc_network_region_subnet_map[region].subnet_ip
      }
    ]
  )
  // We are using an root module defined GLB, so we need this tag to be appended to api nodes, for them to be visible to the GLB. Include development mode firewall tags
  vm_firewall_tags = concat([local.tag_glb_target_node], local.dev_mode_fw_tags)
  // API VMs configuration
  vm_platform_api_image_version = var.config_vm_platform_api_image_version
  vm_api_vcpus                  = var.config_vm_api_vcpus
  vm_api_mem                    = var.config_vm_api_mem
  vm_api_image                  = var.config_vm_api_image
  vm_api_image_project          = var.config_vm_api_image_project
  vm_api_boot_disk_size         = var.config_vm_api_boot_disk_size
  api_v_major                   = var.config_vm_version_major
  api_v_minor                   = var.config_vm_version_minor
  api_v_patch                   = var.config_vm_version_patch
  api_d_year                    = var.config_vm_data_year
  api_d_month                   = var.config_vm_data_month
  api_d_iteration               = var.config_vm_data_iteration
  api_ignore_cache              = var.config_vm_api_ignore_cache
  jvm_xms                       = var.config_api_jvm_xms
  jvm_xmx                       = var.config_api_jvm_xmx
  vm_flag_preemptible           = var.config_vm_api_flag_preemptible
  backend_connection_map = zipmap(
    var.config_deployment_regions,
    [
      for idx, region in var.config_deployment_regions : {
        host_clickhouse     = module.backend_clickhouse[idx].ilb_ip_address
        host_elastic_search = module.backend_elastic_search[idx].ilb_ip_address
      }
    ]
  )
  deployment_regions     = var.config_deployment_regions
  deployment_target_size = 1
  // This can be
  //  INTERNAL   - ILB
  //  GLOBAL    - GLB
  //  NONE      - To not attach a load balancer to the instance groups
  load_balancer_type = "NONE"
  // I have to pass this value until I implement a validation mechanism, but the module won't use it, because it's set to 'NONE' LB
  dns_domain_api              = local.dns_platform_api_dns_name
  common_tags                 = var.common_tags
  node_exporter_image_name    = var.node_exporter_image_name
  node_exporter_image_version = var.node_exporter_image_version
}

// --- Prometheus --- //
module "backend_prometheus" {
  source     = "./modules/prometheus"
  project_id = var.config_project_id
  depends_on = [
    module.vpc_network
  ]
  module_wide_prefix_scope = local.module_wide_prefix_pro
  module_wide_prefix_api   = local.module_wide_prefix_api
  module_wide_prefix_es    = local.module_wide_prefix_es
  module_wide_prefix_ch    = local.module_wide_prefix_ch
  config_release_name      = var.config_release_name
  network_name             = module.vpc_network.network_name
  network_self_link        = module.vpc_network.network_self_link
  network_subnet_name      = local.vpc_network_main_subnet_name
  // We are using an root module defined GLB, so we need this tag to be appended to api nodes, for them to be visible to the GLB. Include development mode firewall tags
  vm_firewall_tags = concat([local.tag_glb_target_node], local.dev_mode_fw_tags)
  // API VMs configuration
  vm_flag_preemptible    = var.config_vm_prometheus_flag_preemptible
  deployment_regions     = var.config_deployment_regions
  deployment_target_size = 1
  // This can be
  //  INTERNAL   - ILB
  //  GLOBAL    - GLB
  //  NONE      - To not attach a load balancer to the instance groups
  load_balancer_type = "NONE"
  // I have to pass this value until I implement a validation mechanism, but the module won't use it, because it's set to 'NONE' LB
  common_tags                 = var.common_tags
  git_branch                  = var.git_branch
  git_repository              = var.git_repository
  node_exporter_image_name    = var.node_exporter_image_name
  node_exporter_image_version = var.node_exporter_image_version
}

// --- Web Application --- //
module "web_app" {
  source                        = "./modules/webapp"
  project_id                    = var.config_project_id
  depends_on                    = [module.vpc_network]
  module_wide_prefix_scope      = local.module_wide_prefix_web
  folder_tmp                    = local.folder_tmp
  location                      = var.config_webapp_location
  webapp_repo_name              = var.config_webapp_repo_name
  webapp_release                = var.config_webapp_release
  webapp_image_version          = var.config_webapp_image_version
  webapp_deployment_context_env = var.config_webapp_deployment_context
  webapp_deployment_context     = var.config_webapp_deployment_context_map
  webapp_robots_profile         = var.config_webapp_robots_profile
  webapp_custom_profile         = var.config_webapp_custom_profile
  // Data Context --- //
  webapp_bucket_data_context_name    = var.config_webapp_bucket_name_data_assets
  webapp_bucket_data_context_release = var.config_webapp_data_context_release
  // Sitemaps Configuration --- //
  webapp_sitemaps_repo_name        = var.config_webapp_sitemaps_repo_name
  webapp_sitemaps_release          = var.config_webapp_sitemaps_release
  webapp_sitemaps_bigquery_table   = var.config_webapp_sitemaps_bigquery_table
  webapp_sitemaps_bigquery_project = var.config_webapp_sitemaps_bigquery_project
  // Web Servers Configuration --- //
  network_name        = module.vpc_network.network_name
  network_self_link   = module.vpc_network.network_self_link
  network_subnet_name = local.vpc_network_main_subnet_name
  network_source_ranges_map = zipmap(
    var.config_deployment_regions,
    [
      for region in var.config_deployment_regions : {
        source_range = local.vpc_network_region_subnet_map[region].subnet_ip
      }
    ]
  )
  //network_sources_health_checks = DEFAULT
  webserver_deployment_regions   = var.config_deployment_regions
  webserver_firewall_tags        = concat([local.tag_glb_target_node], local.dev_mode_fw_tags)
  webserver_docker_image_version = var.config_webapp_webserver_docker_image_version
  webserver_vm_vcpus             = var.config_webapp_webserver_vm_vcpus
  webserver_vm_mem               = var.config_webapp_webserver_vm_mem
  webserver_vm_image             = var.config_webapp_webserver_vm_image
  webserver_vm_image_project     = var.config_webapp_webserver_vm_image_project
  webserver_vm_boot_disk_size    = var.config_webapp_webserver_vm_boot_disk_size
  vm_flag_preemptible            = var.config_vm_webserver_flag_preemptible
  deployment_target_size         = 1
}
