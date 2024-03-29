// --- Application Layer --- //

// Default configuration for the web application is the Development Environment
config_webapp_deployment_context_map = {
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API      = "'https://api.platform.dev.opentargets.xyz/api/v4/graphql'"
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API_BETA = "'https://api.platform.dev.opentargets.xyz/api/v4/graphql'"
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_EFO_URL      = "'/data/ontology/efo_json/diseases_efo.jsonl'"
}
// Data Context bucket, default 'open-targets-pre-data-releases'
config_webapp_bucket_name_data_assets = "open-targets-pre-data-releases"
// Robots.txt profile --- //
//config_webapp_robots_profile = "default"
// Web Application Customisation Profile --- //
// Using the default profile
//config_webapp_custom_profile = "default.js"
