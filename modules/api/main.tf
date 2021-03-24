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

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.deployment_regions)
  
  region = var.deployment_regions[count.index]
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
    google-logging-enabled = true
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "otpapi_healthcheck" {
  name = "${var.module_wide_prefix_scope}-otpapi-healthcheck"
  check_interval_sec = 5
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = local.otp_api_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_otpapi" {
  count = length(var.deployment_regions)

  name = "${var.module_wide_prefix_scope}-${count.index}-regmig-otpapi"
  region = var.deployment_regions[count.index]
  base_instance_name = "${var.module_wide_prefix_scope}-${count.index}-api"
  depends_on = [ 
      google_compute_instance_template.otpapi_template,
      google_compute_firewall.vpc_netfw_otpapi_node
    ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.otpapi_template[count.index].id
  }

  target_size = var.deployment_target_size

  named_port {
    name = local.otp_api_port_name
    port = local.otp_api_port
  }

  auto_healing_policies {
    health_check = google_compute_health_check.otpapi_healthcheck.id
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available[count.index].names)
    max_unavailable_fixed        = 0
    min_ready_sec                = 30
  }
}

// --- AUTOSCALERS --- //
resource "google_compute_region_autoscaler" "autoscaler_otpapi" {
  count = length(var.deployment_regions)

  name = "${var.module_wide_prefix_scope}-${count.index}-autoscaler"
  region = var.deployment_regions[count.index]
  target = google_compute_region_instance_group_manager.regmig_otpapi[count.index].id

  autoscaling_policy {
    max_replicas = 6
    min_replicas = 1
    cooldown_period = 60
    cpu_utilization {
      target = 0.5
    }
  }
}