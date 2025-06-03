// Clickhouse Deployment for Open Target Platform
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a regional Clickhouse deployment behind an ILB
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
    clickhouse_template_tags         = join("", sort(local.clickhouse_template_tags)),
    clickhouse_template_machine_type = local.clickhouse_template_machine_type,
    clickhouse_template_source_image = local.clickhouse_template_source_image,
    clickhouse_data_image            = var.vm_clickhouse_data_volume_snapshot,
    clickhouse_data_snapshot_project = var.vm_clickhouse_data_volume_snapshot_project
    vm_startup_script                = md5(file("${path.module}/scripts/instance_startup.sh"))
    vm_flag_preemptible              = var.vm_flag_preemptible
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  region = var.deployment_region
}

// --- Service Account Configuration ---
resource "google_service_account" "gcp_service_acc_apis" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svc-${random_string.random.result}"
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
resource "google_project_iam_member" "service-agent" {
  project = var.vm_clickhouse_data_volume_snapshot_project
  role    = "roles/compute.serviceAgent"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_apis.email}"
}
// --- /Service Account Configuration/ ---

resource "google_compute_instance_template" "clickhouse_template" {
  name                 = "${var.module_wide_prefix_scope}-clickhouse-template-${random_string.random.result}"
  description          = "Open Targets Platform Clickhouse node template, release ${var.vm_clickhouse_image}"
  instance_description = "Open Targets Platform Clickhouse node, release ${var.vm_clickhouse_image}"
  region               = var.deployment_region

  tags = local.clickhouse_template_tags

  machine_type   = local.clickhouse_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  disk {
    source_image = local.clickhouse_template_source_image
    auto_delete  = true
    disk_type    = "pd-ssd"
    boot         = true
    mode         = "READ_WRITE"
    // Disk size inherited from the image
  }

  // Attach Clickhouse data disk
  disk {
    device_name     = local.clickhouse_data_disk_device
    source_snapshot = local.clickhouse_data_disk_snapshot
    mode            = "READ_WRITE"
    disk_type       = "pd-ssd"
    // Disk size inherited from the image
    //disk_size_gb = var.vm_clickhouse_data_disk_size
    boot        = false
    auto_delete = true
    type        = "PERSISTENT"
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.network_subnet_name
  }

  lifecycle {
    create_before_destroy = true
  }

  // There is no startup script for Clickhouse, it's just available in the image
  metadata = {
    startup-script = templatefile(
      "${path.module}/scripts/instance_startup.sh",
      {
        GCP_DEVICE_DISK_PREFIX   = local.gcp_device_disk_prefix,
        DATA_DISK_DEVICE_NAME_CH = local.clickhouse_data_disk_device,
        DOCKER_IMAGE_CLICKHOUSE  = local.clickhouse_docker_image
      }
    )
    google-logging-enabled = true
  }

  service_account {
    email  = google_service_account.gcp_service_acc_apis.email
    scopes = ["cloud-platform", "logging-write", "monitoring-write"]
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "clickhouse_healthcheck" {
  name                = "${var.module_wide_prefix_scope}-clickhouse-healthcheck"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = local.clickhouse_http_req_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_clickhouse" {
  provider           = google-beta
  name               = "${var.module_wide_prefix_scope}-regmig-clickhouse"
  region             = var.deployment_region
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
    name = local.clickhouse_node_exporter_name
    port = local.clickhouse_node_exporter_port
  }

  named_port {
    name = local.clickhouse_metrics_port_name
    port = local.clickhouse_metrics_port
  }

  named_port {
    name = local.clickhouse_cli_req_port_name
    port = local.clickhouse_cli_req_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.clickhouse_healthcheck.id
    initial_delay_sec = 20
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = length(data.google_compute_zones.available.names)
    max_unavailable_fixed        = 0
    min_ready_sec                = 20
  }
  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }
}


// --- AUTOSCALERS --- //
resource "google_compute_region_autoscaler" "autoscaler_clickhouse" {
  name   = "${var.module_wide_prefix_scope}-autoscaler"
  region = var.deployment_region
  target = google_compute_region_instance_group_manager.regmig_clickhouse.id

  autoscaling_policy {
    max_replicas    = local.compute_zones_n_total * 2
    min_replicas    = 1
    cooldown_period = 30
    cpu_utilization {
      target = 0.65
    }
  }
}
