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
    otpprometheus_template_machine_type = local.otpprometheus_machine_type,
    template_source_image               = data.google_compute_image.main.id,
    vm_startup_script                   = md5(file("${path.module}/scripts/instance_startup.sh")),
    vm_compose                          = md5(file("${path.module}/config/compose.yml")),
    datasources                         = md5(file("${path.module}/config/datasource.yml")),
    vm_flag_preemptible                 = var.vm_flag_preemptible
  }
}

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

resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_service_account_key" "gcp_service_acc_prom_key" {
  service_account_id = google_service_account.gcp_service_acc_prom.name
}

resource "google_compute_instance" "default" {
  count = length(var.deployment_regions)

  name         = "${var.module_wide_prefix_scope}-${count.index}-otprometheus-${random_string.random.result}"
  machine_type = local.otpprometheus_machine_type
  zone         = data.google_compute_zones.available[count.index].names[0]

  tags = concat(local.otpprometheus_template_tags, var.common_tags)

  boot_disk {
    initialize_params {
      image = data.google_compute_image.main.self_link
      type  = "pd-ssd"
    }
    mode        = "READ_WRITE"
    auto_delete = true
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.network_subnet_name
  }

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  metadata = {
    google-logging-enabled = true
    docker_compose = templatefile("${path.module}/config/compose.yml", {
      node_exporter_image = local.node_exporter_image
      prometheus_image    = local.prometheus_image
      prometheus_port     = var.prometheus_container_port
      grafana_image       = local.grafana_image
      grafana_port        = var.grafana_container_port
    })
  }

  metadata_startup_script = templatefile("${path.module}/scripts/instance_startup.sh", {
    svc_acc_key            = replace(base64decode(google_service_account_key.gcp_service_acc_prom_key.private_key), "$", "\\$"),
    available_zones        = join(",", data.google_compute_zones.available[count.index].names)
    instance_prefix        = var.config_release_name
    pro_instance_prefix    = var.module_wide_prefix_scope
    module_wide_prefix_es  = var.module_wide_prefix_es
    module_wide_prefix_ch  = var.module_wide_prefix_ch
    module_wide_prefix_api = var.module_wide_prefix_api
    git_repository         = var.git_repository
    git_branch             = var.git_branch
  })

  service_account {
    email = google_service_account.gcp_service_acc_prom.email
    // TODO: Check if logging and monitoring are needed
    scopes = ["cloud-platform", "logging-write"]
  }

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
}