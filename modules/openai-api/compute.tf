// --- OpenAI API Compute resources --- //
resource "random_string" "openai_api_node" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  keepers = {
    template_tags     = join("", sort(local.fw_vm_tags)),
    machine_type      = local.vm_machine_type,
    source_image      = local.vm_template_source_image,
    docker_fqdn_image = local.openai_api_docker_image,
    startup_script    = md5(file("${path.module}/scripts/vm_startup.sh"))
    openai_token      = var.openai_token
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.deployment_regions)

  region = var.deployment_regions[count.index]
}

// --- Service Account Configuration ---
resource "google_service_account" "gcp_service_acc_openai_api" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svcacc-${random_string.openai_api_node.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

// Roles ---
resource "google_project_iam_member" "logging-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_openai_api.email}"
}

resource "google_project_iam_member" "monitoring-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_openai_api.email}"
}

resource "google_project_iam_member" "secrets-accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_openai_api.email}"

  condition {
    title       = "Access to OpenAI related secrets"
    description = "This condition limits access scope on Cloud Secrets Manager to just the OpenAI related secrets"
    expression  = "resource.name.startsWith(\"${var.openai_token}\")"
  }

}
// --- /Service Account Configuration/ ---

// OpenAI API Compute Instance (VM) ---
resource "google_compute_instance_template" "openai_api_node_template" {
  count = length(var.deployment_regions)

  name                 = "${var.module_wide_prefix_scope}-${count.index}-openai-api-template-${random_string.openai_api_node.result}"
  description          = "OpenAI API node template, docker image ${local.openai_api_docker_image}"
  instance_description = "OpenAI API node, docker image ${local.openai_api_docker_image}"
  region               = var.deployment_regions[count.index]

  tags = local.fw_vm_tags

  machine_type   = local.vm_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  disk {
    source_image = local.vm_template_source_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-ssd"
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
      "${path.module}/scripts/vm_startup.sh",
      {
        openai_token = var.openai_token,
        project_id   = var.project_id,
      }
    )
    docker_compose = templatefile(
      "${path.module}/config/compose.yml",
      {
        openai_api_docker_image   = local.openai_api_docker_image,
        openai_api_external_port  = local.openai_api_port,
        openai_api_internal_port  = local.openai_api_port,
        openai_api_container_name = local.openai_api_container_name,
      }
    )
    google-logging-enabled = "true"
  }

  service_account {
    email  = google_service_account.gcp_service_acc_openai_api.email
    scopes = ["cloud-platform", "logging-write", "monitoring-write"]
  }
}

// --- Health Check definition --- //
resource "google_compute_health_check" "openai_api_node_health_check" {
  name                = "${var.module_wide_prefix_scope}-openai-api-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = local.openai_api_port
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "remig_openai_api" {
  count = length(var.deployment_regions)

  provider           = google-beta
  name               = "${var.module_wide_prefix_scope}-openai-api-remig"
  region             = var.deployment_regions[count.index]
  base_instance_name = "${var.module_wide_prefix_scope}-${count.index}-openai-api"
  depends_on = [
    google_compute_instance_template.openai_api_node_template,
    google_compute_health_check.openai_api_node_health_check
  ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.openai_api_node_template[count.index].self_link
  }

  named_port {
    name = local.openai_api_port_name
    port = local.openai_api_port
  }

  named_port {
    name = local.openai_node_exporter_port_name
    port = local.openai_node_exporter_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.openai_api_node_health_check.self_link
    initial_delay_sec = 30
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    instance_redistribution_type = "PROACTIVE"
    max_surge_fixed              = length(data.google_compute_zones.available[count.index].names)
    max_unavailable_fixed        = length(data.google_compute_zones.available[count.index].names)
    min_ready_sec                = 7
  }

  instance_lifecycle_policy {
    force_update_on_repair = "YES"
  }
}

// --- Autoscalers --- //
resource "google_compute_region_autoscaler" "openai_api_node" {
  count = length(var.deployment_regions)

  name   = "${var.module_wide_prefix_scope}-${count.index}-openai-api-autoscaler"
  region = var.deployment_regions[count.index]
  target = google_compute_region_instance_group_manager.remig_openai_api[count.index].self_link

  autoscaling_policy {
    max_replicas    = length(data.google_compute_zones.available[count.index].names) * 2
    min_replicas    = 1
    cooldown_period = 120
    cpu_utilization {
      target = 0.8
    }
    load_balancing_utilization {
      target = 0.8
    }
  }
}