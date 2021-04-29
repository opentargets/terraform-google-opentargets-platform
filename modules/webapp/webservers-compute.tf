// Definition of active web servers for the web application
resource "random_string" "random_web_server_suffix" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    webapp_bucket_name = local.bucket_name
    // TODO - nginx version
  }
}

// TODO - Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.webserver_deployment_regions)
  
  region = var.webserver_deployment_regions[count.index]
}

// TODO - Service Account --- //
resource "google_service_account" "gcp_service_acc_apis" {
  account_id = "${var.module_wide_prefix_scope}-svcacc-${random_string.random_web_server_suffix.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}
// TODO - Instance Template --- //
// TODO - Helath Check --- //
// TODO - RegMIG --- //
// TODO - Autoscalers --- //
