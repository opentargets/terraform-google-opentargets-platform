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
  keepers = merge({
    otpprometheus_template_tags         = join("", sort(local.otpprometheus_template_tags)),
    otpprometheus_template_machine_type = local.otpprometheus_machine_type,
    template_source_image               = data.google_compute_image.main.id,
    cloud-init                          = md5(file("${path.module}/config/cloud-init.yaml")),
    datasources                         = md5(file("${path.module}/config/datasource.yml")),
    alloy-config                        = md5(file("${path.module}/config/config.alloy")),
    loki-config                         = md5(file("${path.module}/config/loki-config.yml")),
    dashboards                          = join("-", fileset("${path.module}/config/dashboards", "*.json"))
    vm_flag_preemptible                 = var.vm_flag_preemptible
  }, local.dashboards_md5) //TODO: Calculate md5 of the dashboards
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

resource "google_project_iam_member" "storage" {
  project = var.project_id
  role    = "roles/storage.admin"
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

resource "google_compute_disk" "prometheus_data" {
  count = length(var.deployment_regions)

  name = "${var.module_wide_prefix_scope}-${count.index}-prometheus-data-${random_string.random.result}"
  type = "pd-ssd"
  zone = data.google_compute_zones.available[count.index].names[0]
  size = var.vm_prometheus_data_disk_size

  labels = {
    component = "prometheus"
    purpose   = "data-storage"
  }
}

resource "google_storage_bucket" "log-storage" {
  name          = "log-storage-${random_string.random.result}"
  location      = "EU"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
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

  attached_disk {
    source      = google_compute_disk.prometheus_data[count.index].id
    device_name = local.otp_prometheus_disk_name
    mode        = "READ_WRITE"
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
    user-data = templatefile("${path.module}/config/cloud-init.yaml", {
      git_repository              = var.git_repository
      git_branch                  = var.git_branch
      node_exporter_image         = local.node_exporter_image
      prometheus_image            = local.prometheus_image
      prometheus_port             = var.prometheus_container_port
      prometheus_retention_period = var.vm_prometheus_retention_period
      prometheus_disk_name        = local.otp_prometheus_disk_name
      grafana_image               = local.grafana_image
      grafana_port                = var.grafana_container_port
      grafana_password            = random_password.grafana_password.result
    })
    config-alloy = templatefile("${path.module}/config/config.alloy", {})
    loki-config = templatefile("${path.module}/config/loki-config.yml", {
      bucket_path = google_storage_bucket.log-storage.url
      svc-account = replace(base64decode(google_service_account_key.gcp_service_acc_prom_key.private_key), "$", "\\$"),
    })
    prom-config = yamlencode(local.prometheus_config_file)
    svc-account = replace(base64decode(google_service_account_key.gcp_service_acc_prom_key.private_key), "$", "\\$"),
  }

  service_account {
    email = google_service_account.gcp_service_acc_prom.email
    // TODO: Check if logging and monitoring are needed
    scopes = ["cloud-platform", "logging-write", "storage-full"]
  }

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
}