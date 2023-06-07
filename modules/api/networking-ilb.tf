// --- This networking definition configures a per region Internal Load Balancing mechanism for accessing the deployment --- //
// --- INTERNAL LOAD BALANCER --- //
// TODO - Refactor with
//      https://github.com/terraform-google-modules/terraform-google-lb-internal
// Forwarding rule
resource "google_compute_forwarding_rule" "ilb_forwarding_rule" {
  // Calculate whether this will be deployed and how many
  count = (var.load_balancer_type == local.lb_type_internal ? 1 : 0) * length(var.deployment_regions)

  name                  = "${var.module_wide_prefix_scope}-${count.index}-ilb-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  network               = var.network_self_link
  region                = var.deployment_regions[count.index]
  subnetwork            = var.network_subnet_name
  backend_service       = google_compute_region_backend_service.ilb_backend_service[count.index].id
  ports                 = [local.otp_api_port]
  depends_on = [
    google_compute_region_backend_service.ilb_backend_service
  ]
}

// Backend Service
resource "google_compute_region_backend_service" "ilb_backend_service" {
  // Calculate whether this will be deployed and how many
  count = (var.load_balancer_type == local.lb_type_internal ? 1 : 0) * length(var.deployment_regions)

  name                  = "${var.module_wide_prefix_scope}-${count.index}-ilb-backend-service"
  region                = var.deployment_regions[count.index]
  depends_on = [
    google_compute_region_instance_group_manager.regmig_otpapi
  ]

  load_balancing_scheme = "INTERNAL"
  enable_cdn = false
  backend {
    group = google_compute_region_instance_group_manager.regmig_otpapi[count.index].instance_group
    //balancing_mode = "UTILIZATION"
    //capacity_scaler = 1.0
  }

  protocol    = "TCP"
  timeout_sec = 10

  health_checks = [google_compute_region_health_check.ilb_backend_healthcheck[count.index].id]
}

// Health Checks
resource "google_compute_region_health_check" "ilb_backend_healthcheck" {
  // Calculate whether this will be deployed and how many
  count = (var.load_balancer_type == local.lb_type_internal ? 1 : 0) * length(var.deployment_regions)

  name   = "${var.module_wide_prefix_scope}-${count.index}-ilb-backend-healthcheck"
  region = var.deployment_regions[count.index]

  tcp_health_check {
    port = local.otp_api_port
  }
}
