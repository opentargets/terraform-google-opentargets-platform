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
  ports = [ local.elastic_search_port_requests ]
  depends_on = [
      google_compute_region_backend_service.ilb_backend_service
    ]
}

