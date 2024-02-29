// --- INTERNAL LOAD BALANCER --- //
// TODO - Refactor with
//      https://github.com/terraform-google-modules/terraform-google-lb-internal

// URL Map
resource "google_compute_region_url_map" "ilb_url_map" {
  name   = "${var.module_wide_prefix_scope}-ilb-url-map"
  provider = google-beta
  region = var.deployment_region

  default_service = google_compute_region_backend_service.ilb_backend_service.id

  depends_on = [
    google_compute_region_backend_service.ilb_backend_service
  ]
}

// Define the HTTP target proxy
resource "google_compute_region_target_http_proxy" "ilb_target_http_proxy" {
  name   = "${var.module_wide_prefix_scope}-ilb-target-http-proxy"

  provider = google-beta
  region = var.deployment_region

  url_map = google_compute_region_url_map.ilb_url_map.id
}

// Forwarding rule
resource "google_compute_forwarding_rule" "ilb_forwarding_rule" {
  name                  = "${var.module_wide_prefix_scope}-ilb-forwarding-rule"
  provider = google-beta
  region                = var.deployment_region

  network               = var.network_self_link
  subnetwork            = var.network_subnet_name

  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range = local.elastic_search_port_requests

  target = google_compute_region_target_http_proxy.ilb_target_http_proxy.id
  depends_on = [
    google_compute_region_target_http_proxy.ilb_target_http_proxy
  ]
}

// Backend Service
resource "google_compute_region_backend_service" "ilb_backend_service" {
  name                  = "${var.module_wide_prefix_scope}-ilb-backend-service"
  provider = google-beta
  region                = var.deployment_region

  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = 10
  health_checks = [google_compute_region_health_check.ilb_backend_healthcheck.id]

  depends_on = [
    google_compute_region_instance_group_manager.regmig_elastic_search
  ]
  backend {
    group = google_compute_region_instance_group_manager.regmig_elastic_search.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

// Health Checks
resource "google_compute_region_health_check" "ilb_backend_healthcheck" {
  name   = "${var.module_wide_prefix_scope}-ilb-backend-healthcheck"
  region = var.deployment_region

  tcp_health_check {
    // Elastic Search Requests Port
    port = local.elastic_search_port_requests
  }
}

