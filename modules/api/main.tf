// Open Targets Platform API deployment definition
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a multi-regional deployment of Open Target Platform API
*/

// --- Machine Template --- //
// TODO - Refactor using
//      https://github.com/terraform-google-modules/terraform-google-vm
resource "random_string" "random" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    otpapi_template_tags          = join("", sort(local.otpapi_template_tags)),
    otpapi_template_machine_type  = local.otpapi_template_machine_type,
    otpapi_template_source_image  = local.otpapi_template_source_image,
    vm_platform_api_image_version = var.vm_platform_api_image_version,
    vm_platform_api_image_version = var.vm_platform_api_image_version,
    vm_startup_script             = md5(file("${path.module}/scripts/instance_startup.sh")),
    vm_flag_preemptible           = var.vm_flag_preemptible,
    vm_api_version_major          = var.api_v_major,
    vm_api_version_minor          = var.api_v_minor,
    vm_api_version_patch          = var.api_v_patch,
    vm_api_data_year              = var.api_d_year,
    vm_api_data_month             = var.api_d_month,
    vm_api_data_iter              = var.api_d_iteration,
    vm_api_ignore_cache           = var.api_ignore_cache,
    jvm_xms                       = var.jvm_xms,
    jvm_xmx                       = var.jvm_xmx
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.deployment_regions)

  region = var.deployment_regions[count.index]
}

// --- Service Account Configuration ---
resource "google_service_account" "gcp_service_acc_apis" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svcacc-${random_string.random.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

// Roles ---
resource "google_project_iam_member" "logging-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_apis.email}"
}
resource "google_project_iam_member" "monitoring-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_apis.email}"
}
// --- /Service Account Configuration/ ---

resource "google_compute_instance_template" "otpapi_template" {
  count = length(var.deployment_regions)

  name                 = "${var.module_wide_prefix_scope}-${count.index}-otpapi-template-${random_string.random.result}"
  description          = "Open Targets Platform API node template, API docker image version ${var.vm_platform_api_image_version}"
  instance_description = "Open Targets Platform API node, API docker image version ${var.vm_platform_api_image_version}"
  region               = var.deployment_regions[count.index]


  tags = concat(local.otpapi_template_tags, var.common_tags)

  machine_type   = local.otpapi_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  disk {
    source_image = local.otpapi_template_source_image
    auto_delete  = true
    disk_type    = "pd-ssd"
    boot         = true
    mode         = "READ_WRITE"
  }

  network_interface {
    network    = var.network_name
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
        ELASTICSEARCH_HOST   = var.backend_connection_map[var.deployment_regions[count.index]].host_elastic_search,
        PLATFORM_API_VERSION = var.vm_platform_api_image_version,
        OTP_API_PORT         = local.otp_api_port,
        API_VERSION_MAJOR    = var.api_v_major,
        API_VERSION_MINOR    = var.api_v_minor,
        API_VERSION_PATCH    = var.api_v_patch,
        API_DATA_YEAR        = var.api_d_year,
        API_DATA_MONTH       = var.api_d_month,
        API_DATA_ITER        = var.api_d_iteration,
        API_IGNORE_CACHE     = var.api_ignore_cache
        JVM_XMS              = var.jvm_xms,
        JVM_XMX              = var.jvm_xmx
      }
    )
    google-logging-enabled = true
  }

  service_account {
    // This is useless anyway, maybe it's not covered by the google provider
    email = google_service_account.gcp_service_acc_apis.email
    // This WAS SUPPOSED TO BE LEGACY...
    scopes = ["cloud-platform", "logging-write", "monitoring-write"]
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "otpapi_healthcheck" {
  name                = "${var.module_wide_prefix_scope}-otpapi-healthcheck"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = local.otp_api_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_otpapi" {
  count = length(var.deployment_regions)

  provider           = google-beta
  name               = "${var.module_wide_prefix_scope}-${count.index}-regmig-otpapi"
  region             = var.deployment_regions[count.index]
  base_instance_name = "${var.module_wide_prefix_scope}-${count.index}-api"
  depends_on = [
    google_compute_instance_template.otpapi_template,
    google_compute_firewall.vpc_netfw_otpapi_node
  ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.otpapi_template[count.index].id
  }

  //target_size = var.deployment_target_size

  named_port {
    name = local.otp_api_port_name
    port = local.otp_api_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.otpapi_healthcheck.id
    initial_delay_sec = 20
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available[count.index].names)
    max_unavailable_fixed        = length(data.google_compute_zones.available[count.index].names)
    min_ready_sec                = 20
  }

  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }
}

// --- AUTOSCALERS --- //
resource "google_compute_region_autoscaler" "autoscaler_otpapi" {
  count = length(var.deployment_regions)

  name   = "${var.module_wide_prefix_scope}-${count.index}-autoscaler"
  region = var.deployment_regions[count.index]
  target = google_compute_region_instance_group_manager.regmig_otpapi[count.index].id

  autoscaling_policy {
    max_replicas    = length(data.google_compute_zones.available[count.index].names) * 2
    min_replicas    = 1
    cooldown_period = 120
    //    load_balancing_utilization {
    //      target = 0.6
    //    }
    cpu_utilization {
      target = 0.65
    }
  }
}
