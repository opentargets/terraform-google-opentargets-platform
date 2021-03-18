// Open Targets Platform API deployment definition
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a multi-regional deployment of Open Target Platform API
*/

// --- Machine Template --- //
// TODO - Refactor using
//      https://github.com/terraform-google-modules/terraform-google-vm
resource "random_string" "random" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    otpapi_template_tags = join("", sort(local.otpapi_template_tags)),
    otpapi_template_machine_type = local.otpapi_template_machine_type,
    otpapi_template_source_image = local.otpapi_template_source_image,
    vm_platform_api_image_version = var.vm_platform_api_image_version
  }
}

resource "google_compute_instance_template" "otpapi_template" {
  count = length(var.deployment_regions)

  name = "${var.module_wide_prefix_scope}-${count.index}-otpapi-template-${random_string.random.result}"
  description = "Open Targets Platform API node template, API docker image version ${var.vm_platform_api_image_version}"
  instance_description = "Open Targets Platform API node, API docker image version ${var.vm_platform_api_image_version}"
  region = var.deployment_regions[count.index]
  
  
  tags = local.otpapi_template_tags

  machine_type = local.otpapi_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = local.otpapi_template_source_image
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
      "${path.module}/scripts/instance_startup.sh",
      {
        SLICK_CLICKHOUSE_URL = "jdbc:clickhouse://${var.backend_connection_map[var.deployment_regions[count.index]].host_clickhouse}:8123",
        ELASTICSEARCH_HOST = var.backend_connection_map[var.deployment_regions[count.index]].host_elastic_search,
        PLATFORM_API_VERSION = var.vm_platform_api_image_version,
        OTP_API_PORT = local.otp_api_port
      }
    )
  }
}

