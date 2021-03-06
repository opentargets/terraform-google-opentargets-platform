// Clickhouse Deployment for Open Target Platform
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a regional Clickhouse deployment behind an ILB
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
    clickhouse_template_tags = join("", sort(local.clickhouse_template_tags)),
    clickhouse_template_machine_type = local.clickhouse_template_machine_type,
    clickhouse_template_source_image = local.clickhouse_template_source_image
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  region = var.deployment_region
}

resource "google_service_account" "gcp_service_acc_apis" {
  account_id = "${var.module_wide_prefix_scope}-svc-${random_string.random.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

resource "google_compute_instance_template" "clickhouse_template" {
  name = "${var.module_wide_prefix_scope}-clickhouse-template-${random_string.random.result}"
  description = "Open Targets Platform Clickhouse node template, release ${var.vm_clickhouse_image}"
  instance_description = "Open Targets Platform Clickhouse node, release ${var.vm_clickhouse_image}"
  region = var.deployment_region
  
  tags = local.clickhouse_template_tags

  machine_type = local.clickhouse_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = local.clickhouse_template_source_image
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

  // There is no startup script for Clickhouse, it's just available in the image
  metadata = {
    google-logging-enabled = true
  }

  service_account {
    email = google_service_account.gcp_service_acc_apis.email
    scopes = [ "cloud-platform" ]
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "clickhouse_healthcheck" {
  name = "${var.module_wide_prefix_scope}-clickhouse-healthcheck"
  check_interval_sec = 5
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = local.clickhouse_http_req_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_clickhouse" {
  name = "${var.module_wide_prefix_scope}-regmig-clickhouse"
  region = var.deployment_region
  base_instance_name = "${var.module_wide_prefix_scope}-clickhouse"
  depends_on = [ 
      google_compute_instance_template.clickhouse_template,
      google_compute_firewall.vpc_netfw_clickhouse_node
    ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.clickhouse_template.id
  }

  //target_size = var.deployment_target_size

  named_port {
    name = local.clickhouse_http_req_port_name
    port = local.clickhouse_http_req_port
  }

  named_port {
    name = local.clickhouse_cli_req_port_name
    port = local.clickhouse_cli_req_port
  }

  auto_healing_policies {
    health_check = google_compute_health_check.clickhouse_healthcheck.id
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available.names)
    max_unavailable_fixed        = 0
    min_ready_sec                = 30
  }
}

// --- AUTOSCALERS --- //
resource "google_compute_region_autoscaler" "autoscaler_clickhouse" {
  name = "${var.module_wide_prefix_scope}-autoscaler"
  region = var.deployment_region
  target = google_compute_region_instance_group_manager.regmig_clickhouse.id

  autoscaling_policy {
    max_replicas = local.compute_zones_n_total * 2
    min_replicas = 1
    cooldown_period = 60
    cpu_utilization {
      target = 0.75
    }
  }
}
