// Definition of active web servers for the web application
resource "random_string" "random_web_server_suffix" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    webapp_bucket_name = local.bucket_name
    deployment_bundle_filename = local.webapp_deployment_bundle_filename
    deployment_bundle_url = local.webapp_deployment_bundle_url
    nginx_docker_image_version = var.webserver_docker_image_version
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.webserver_deployment_regions)
  
  region = var.webserver_deployment_regions[count.index]
}

// Service Account --- //
resource "google_service_account" "gcp_service_acc_apis" {
  account_id = "${var.module_wide_prefix_scope}-svcacc-${random_string.random_web_server_suffix.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

// Instance Template --- //
resource "google_compute_instance_template" "webserver_template" {
  count = length(var.webserver_deployment_regions)

  name = "${var.module_wide_prefix_scope}-${count.index}-webserver-template-${random_string.random_web_server_suffix.result}"
  description = "Open Targets Platform Web Server node template"
  instance_description = "Open Targets Platform Web Server node, docker image version ${var.webserver_docker_image_version}"
  region = var.webserver_deployment_regions[count.index]
  
  
  tags = local.webapp_webserver_template_tags

  machine_type = local.webapp_webserver_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = local.webapp_webserver_template_source_image
    auto_delete = true
    disk_type = "pd-ssd"
    boot = true
    mode = "READ_WRITE"
  }

  network_interface {
    network = var.network_name
    subnetwork = var.network_subnet_name
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    startup-script = templatefile(
      "${path.module}/scripts/webserver_vm_startup_script.sh",
      {
        deployment_bundle_url = local.webapp_deployment_bundle_url
        deployment_bundle_filename = local.webapp_deployment_bundle_filename
        docker_image_version = var.webserver_docker_image_version
      }
    )
    google-logging-enabled = true
  }

  service_account {
    email = google_service_account.gcp_service_acc_apis.email
    scopes = [ "cloud-platform" ]
  }
}
// TODO - Helath Check --- //
// TODO - RegMIG --- //
// TODO - Autoscalers --- //
