// Open Targets Platform Prometheus deployment definition
// Author: Ricardo Esteban Martinez Osorio <remo87@gmail.com>

/*
    This module defines a multi-regional deployment of Open Target Platform Prometheus
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
    otpprometheus_template_tags         = join("", sort(local.otpprometheus_template_tags)),
    otpprometheus_template_machine_type = local.otpprometheus_template_machine_type,
    vm_startup_script                   = md5(file("${path.module}/scripts/instance_startup.sh")),
    vm_compose                          = md5(file("${path.module}/config/compose.yml")),
    vm_prometheus                       = md5(file("${path.module}/config/prometheus.yml")),
    vm_flag_preemptible                 = var.vm_flag_preemptible
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.deployment_regions)

  region = var.deployment_regions[count.index]
}

// --- Service Account Configuration ---
resource "google_service_account" "gcp_service_acc_prom" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svcacc-${random_string.random.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

// Roles ---
resource "google_project_iam_member" "logging-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_prom.email}"
}
resource "google_project_iam_member" "monitoring-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_prom.email}"
}

# This is needed for the discovery of the instance by the prometheus service
resource "google_project_iam_member" "network-viewer" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_prom.email}"
}

resource "google_service_account_key" "gcp_service_acc_prom_key" {
  service_account_id = google_service_account.gcp_service_acc_prom.name
}
// --- /Service Account Configuration/ ---

resource "google_compute_instance_template" "otpprometheus_template" {
  count = length(var.deployment_regions)

  name                 = "${var.module_wide_prefix_scope}-${count.index}-otprometheus-template-${random_string.random.result}"
  description          = "Open Targets Platform Prometheus node template, Prometheus docker image version XXXX and Grafana XXXX" //TODO: Set the description to the versions used
  instance_description = "Open Targets Platform Prometheus node, Prometheus docker image version XXXX and Grafana XXXX"
  region               = var.deployment_regions[count.index]

  tags = concat(local.otpprometheus_template_tags, var.common_tags)

  machine_type   = local.otpprometheus_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  disk {
    source_image = local.otpprometheus_template_source_image
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
    startup-script = templatefile("${path.module}/scripts/instance_startup.sh", {
      svc_acc_key            = replace(base64decode(google_service_account_key.gcp_service_acc_prom_key.private_key), "$", "\\$"),
      available_zones        = join(",", data.google_compute_zones.available[count.index].names)
      instance_prefix        = var.config_release_name
      pro_instance_prefix    = var.module_wide_prefix_scope
      module_wide_prefix_es  = var.module_wide_prefix_es
      module_wide_prefix_api = var.module_wide_prefix_api
    })
    google-logging-enabled = true
  }

  service_account {
    // This is useless anyway, maybe it's not covered by the google provider
    email = google_service_account.gcp_service_acc_prom.email
    // This WAS SUPPOSED TO BE LEGACY...
    // TODO: Check if logging and monitoring are needed
    scopes = ["cloud-platform", "logging-write", "monitoring-write"]
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "otpprometheus_healthcheck" {
  name                = "${var.module_wide_prefix_scope}-otprometheus-healthcheck"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = local.otp_prometheus_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_otprometheus" {
  count = length(var.deployment_regions)

  provider           = google-beta
  name               = "${var.module_wide_prefix_scope}-${count.index}-regmig-otprometheus"
  region             = var.deployment_regions[count.index]
  base_instance_name = "${var.module_wide_prefix_scope}-${count.index}-prometheus"
  depends_on = [
    google_compute_instance_template.otpprometheus_template,
    google_compute_firewall.vpc_netfw_otprometheus_node
  ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.otpprometheus_template[count.index].id
  }

  //target_size = var.deployment_target_size

  named_port {
    name = local.otp_prometheus_port_name
    port = local.otp_prometheus_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.otpprometheus_healthcheck.id
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
resource "google_compute_region_autoscaler" "autoscaler_otprometheus" {
  count = length(var.deployment_regions)

  name   = "${var.module_wide_prefix_scope}-${count.index}-autoscaler"
  region = var.deployment_regions[count.index]
  target = google_compute_region_instance_group_manager.regmig_otprometheus[count.index].id

  autoscaling_policy {
    max_replicas    = 1
    min_replicas    = 1
    cooldown_period = 120
    //    load_balancing_utilization {
    //      target = 0.6
    //    }
  }
}
