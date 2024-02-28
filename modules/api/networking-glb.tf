// --- This networking definition configures a Global Load Balancer with external IP for external access --- //

// --- GLOBAL LOAD BALANCER --- //
module "gce_lb_http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = ">= 7.0.0"

  count = (var.load_balancer_type == local.lb_type_global ? 1 : 0)

  project           = var.project_id
  name              = "${var.module_wide_prefix_scope}-glb"
  target_tags       = [local.glb_tag_target_node]
  firewall_networks = [var.network_name]

  // SSL Configuration
  ssl                             = true
  managed_ssl_certificate_domains = [var.dns_domain_api]
//  use_ssl_certificates            = false
  https_redirect                  = true

  backends = {
    default = {
      description             = "Default backend configuration for OTP API"
      protocol                = "HTTP"
      port                    = local.otp_api_port
      port_name               = local.otp_api_port_name
      timeout_sec             = 10
      enable_cdn              = false
      compression_mode        = null
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = null
      edge_security_policy    = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/_ah/health"
        port                = local.otp_api_port
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      // Connect all the defined backends
      groups = [
        for idx, remig in google_compute_region_instance_group_manager.regmig_otpapi : {
          # Each node pool instance group should be added to the backend.
          group                        = google_compute_region_instance_group_manager.regmig_otpapi[idx].instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
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
