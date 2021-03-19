// --- Sample deployment ---//
// --- Release information --- //
config_release_name                         = "mbotp"
// --- Deployment configuration --- //
config_gcp_default_region                   = "europe-west1"
config_gcp_default_zone                     = "europe-west1-b"
config_project_id                           = "open-targets-eu-dev"
config_deployment_regions                   = [ "europe-west2" ]
// --- Elastic Search configuration --- //
config_vm_elastic_search_image_project      = "open-targets-platform"
config_vm_elastic_search_vcpus              = "8"
config_vm_elastic_search_mem                = "53248"
config_vm_elastic_search_image              = "platform-210210-105028-21-02-3-es"
config_vm_elastic_search_version            = "7.7.0"
config_vm_elastic_search_boot_disk_size     = "500GB"
// --- Clickhouse configuration --- //
config_vm_clickhouse_vcpus                  = "4"
config_vm_clickhouse_mem                    = "26624"
config_vm_clickhouse_image                  = "clickhouse-ot-platform-ch-21-02"
config_vm_clickhouse_image_project          = "open-targets-platform"
config_vm_clickhouse_boot_disk_size         = "250GB"
// --- API configuration --- //
config_vm_platform_api_image_version        = "0.55.8"
config_vm_api_vcpus                         = "2"
config_vm_api_mem                           = "7680"
config_vm_api_image                         = "cos-stable"
config_vm_api_image_project                 = "cos-cloud"
config_vm_api_boot_disk_size                = "10GB"
// --- DNS --- //
config_dns_project_id                       = "open-targets-eu-dev"
config_dns_subdomain_prefix                 = "mbdev"
config_dns_managed_zone_name                = "opentargets-xyz"
config_dns_managed_zone_dns_name            = "opentargets.xyz."
config_dns_platform_api_subdomain           = "api"
// --- Web App configuration --- //
config_webapp_repo_name                     = "mbdebian/platform-app"
config_webapp_release                       = "1.0.7"
config_webapp_deployment_context_map        = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT = "'https://api.mbdev.opentargets.xyz/api/v4/graphql'"
}
// --- Development Mode --- //
config_set_dev_mode_on                      = true
