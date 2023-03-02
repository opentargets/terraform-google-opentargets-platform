// --- Platform Global Load Balancer --- //
// This file defines a Global Load Balancer for the platform (L7 with SSL Termination)

// --- GLB SSL Managed Certificates --- //
resource "google_compute_managed_ssl_certificate" "glb_ssl_cert" {
  count = length(local.ssl_managed_certificate_domain_names)

  name = "${var.config_release_name}-ssl-cert-${md5(local.ssl_managed_certificate_domain_names[count.index])}"

  managed {
    domains = [local.ssl_managed_certificate_domain_names[count.index]]
  }
}

// --- GLB Randomization for the resource --- //
resource "random_string" "random_netglb" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    release_name               = var.config_release_name
    dns_subdomain_prefix       = var.config_dns_subdomain_prefix
    dns_managed_zone_name      = var.config_dns_managed_zone_name
    dns_managed_zone_dns_name  = var.config_dns_managed_zone_dns_name
    dns_platform_api_subdomain = var.config_dns_platform_api_subdomain
    // TODO - We need to trigger a change when removing regions from the deployment
  }
}

// --- Platform Global Load Balancer --- //
// URL Map
resource "google_compute_url_map" "url_map_platform_glb" {
  name = "${var.config_release_name}-glb-platform-${random_string.random_netglb.result}"
  // Web frontend as default service
  default_service = module.glb_platform.backend_services["default"].self_link

  // Hosts - Web Application ---
  host_rule {
    hosts        = local.glb_dns_platform_webapp_domain_names
    path_matcher = "webapp-paths"
  }
  // Hosts - Platform API ---
  host_rule {
    hosts        = local.glb_dns_platform_api_dns_names
    path_matcher = "api-paths"
  }
  // Path Matchers --- //
  // Paths - Web Application ---
  path_matcher {
    name            = "webapp-paths"
    default_service = module.glb_platform.backend_services["default"].self_link
  }
  // Paths - Platform API ---
  path_matcher {
    name            = "api-paths"
    default_service = module.glb_platform.backend_services["platformapi"].self_link
  }
}

module "glb_platform" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = ">= 7.0.0"

  // Dependencies
  depends_on = [
    module.vpc_network /*,
    module.web_app,
    module.backend_api*/
  ]

  project           = var.config_project_id
  name              = "${var.config_release_name}-glb-${random_string.random_netglb.result}"
  target_tags       = [local.tag_glb_target_node]
  firewall_networks = [module.vpc_network.network_name]

  // Custom URL Map
  create_url_map = false
  url_map        = google_compute_url_map.url_map_platform_glb.self_link

  // SSL Configuration
  ssl = true
  // managed_ssl_certificate_domains = local.ssl_managed_certificate_domain_names
  use_ssl_certificates = true
  ssl_certificates     = google_compute_managed_ssl_certificate.glb_ssl_cert.*.self_link
  https_redirect       = true

  backends = {
    // Web application is the default backend
    default = {
      description             = "The Web Application is the default backend"
      protocol                = "HTTP"
      port                    = module.web_app.webserver_port
      port_name               = module.web_app.webserver_port_name
      timeout_sec             = 10
      enable_cdn              = local.glb_webapp_cdn_enabled
      compression_mode        = null
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = local.glb_netsec_effective_policy_webapp

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = module.web_app.webserver_port
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        for region, regmig in module.web_app.map_region_to_instance_group_manager : {
          group                        = regmig.instance_group
          balancing_mode               = "RATE"
          capacity_scaler              = null
          description                  = "Web App backend for region '${region}'"
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = 512
          max_rate_per_endpoint        = null
          max_utilization              = 0.85
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
    // Platform API
    platformapi = {
      description             = "Backend configuration for Open Targets Platform API"
      protocol                = "HTTP"
      port                    = module.backend_api.api_port
      port_name               = module.backend_api.api_port_name
      timeout_sec             = 10
      enable_cdn              = false
      compression_mode        = null
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = local.glb_netsec_effective_policy_api

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/_ah/health"
        port                = module.backend_api.api_port
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      // Connect all the API instance groups
      groups = [
        for region, regmig in module.backend_api.map_region_to_instance_group_manager : {
          group                        = regmig.instance_group
          balancing_mode               = "RATE"
          capacity_scaler              = null
          description                  = "API backend for region '${region}'"
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = 50
          max_rate_per_endpoint        = null
          max_utilization              = 0.95
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}
