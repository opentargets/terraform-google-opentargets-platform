// CLOUD ROUTERS --- //
// TODO - Replace with modules
//      https://github.com/terraform-google-modules/terraform-google-cloud-router
//      https://github.com/terraform-google-modules/terraform-google-cloud-nat
resource "google_compute_router" "vpc_subnet_router" {
  count = length(var.config_deployment_regions)

  name       = "router-${var.config_release_name}-${var.config_deployment_regions[count.index]}"
  region     = var.config_deployment_regions[count.index]
  network    = module.vpc_network.network_self_link
  depends_on = [module.vpc_network]

}

resource "google_compute_router_nat" "vpc_subnet_router_nat" {
  count = length(var.config_deployment_regions)

  name                               = "router-nat-${var.config_release_name}-${var.config_deployment_regions[count.index]}"
  router                             = google_compute_router.vpc_subnet_router[count.index].name
  region                             = google_compute_router.vpc_subnet_router[count.index].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on                         = [google_compute_router.vpc_subnet_router]
}