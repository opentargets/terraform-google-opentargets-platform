// --- INTERNAL LOAD BALANCER --- //
// TODO - Refactor with
//      https://github.com/terraform-google-modules/terraform-google-lb-internal
// Forwarding rule
resource "google_compute_forwarding_rule" "ilb_forwarding_rule" {
  name = "${var.module_wide_prefix_scope}-ilb-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  network = var.network_self_link
  region = var.deployment_region
  subnetwork = var.network_subnet_name
  backend_service = google_compute_region_backend_service.ilb_backend_service.id
  ports = [
    local.clickhouse_http_req_port,
    local.clickhouse_cli_req_port
  ]
  depends_on = [
      google_compute_region_backend_service.ilb_backend_service
    ]
}

// Backend Service
resource "google_compute_region_backend_service" "ilb_backend_service" {
  name = "${var.module_wide_prefix_scope}-ilb-backend-service"
  region = var.deployment_region
  load_balancing_scheme = "INTERNAL"
  depends_on = [
      google_compute_region_instance_group_manager.regmig_clickhouse
    ]

  backend {
    group = google_compute_region_instance_group_manager.regmig_clickhouse.instance_group
    //balancing_mode = "UTILIZATION"
    //capacity_scaler = 1.0
  }

  protocol = "TCP"
  timeout_sec = 10

  health_checks = [ google_compute_region_health_check.ilb_backend_healthcheck.id ]
}

// Health Checks
resource "google_compute_region_health_check" "ilb_backend_healthcheck" {
  name = "${var.module_wide_prefix_scope}-ilb-backend-healthcheck"
  region = var.deployment_region

  tcp_health_check {
    // Clickhouse HTTP request port
    port = local.clickhouse_http_req_port
  }
}

