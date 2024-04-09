// Definition of active web servers for the web application
resource "random_string" "random_web_server_suffix" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    webapp_bucket_name         = local.bucket_name
    deployment_bundle_filename = local.webapp_deployment_bundle_filename
    deployment_bundle_url      = local.webapp_deployment_bundle_url
    nginx_docker_image_version = var.webserver_docker_image_version
    startup_script             = md5(file("${path.module}/scripts/webserver_vm_startup_script.sh"))
    vm_flag_preemptible        = var.vm_flag_preemptible
  }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.webserver_deployment_regions)

  region = var.webserver_deployment_regions[count.index]
}

// Service Account --- //
resource "google_service_account" "gcp_service_acc_apis" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svcacc-${random_string.random_web_server_suffix.result}"
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

// Instance Template --- //
resource "google_compute_instance_template" "webserver_template" {
  count = length(var.webserver_deployment_regions)

  name                 = "${var.module_wide_prefix_scope}-${count.index}-webserver-template-${random_string.random_web_server_suffix.result}"
  description          = "Open Targets Platform Web Server node template"
  instance_description = "Open Targets Platform Web Server node, docker image version ${var.webserver_docker_image_version}"
  region               = var.webserver_deployment_regions[count.index]


  tags = local.webapp_webserver_template_tags

  machine_type   = local.webapp_webserver_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart           = !var.vm_flag_preemptible
    on_host_maintenance         = var.vm_flag_preemptible ? "TERMINATE" : "MIGRATE"
    preemptible                 = var.vm_flag_preemptible
    provisioning_model          = var.vm_flag_preemptible ? "SPOT" : "STANDARD"
    instance_termination_action = var.vm_flag_preemptible ? "STOP" : null
  }

  disk {
    source_image = local.webapp_webserver_template_source_image
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
      "${path.module}/scripts/webserver_vm_startup_script.sh",
      {
        dev_www_data_disk          = local.webapp_webserver_disk_web_dev_name
        deployment_bundle_url      = local.webapp_deployment_bundle_url
        deployment_bundle_filename = local.webapp_deployment_bundle_filename
        docker_image_version       = var.webserver_docker_image_version
      }
    )
    google-logging-enabled = true
  }

  service_account {
    email  = google_service_account.gcp_service_acc_apis.email
    scopes = ["cloud-platform", "logging-write", "monitoring-write"]
  }
}

// TODO - Helath Check --- //
resource "google_compute_health_check" "webserver_healthcheck" {
  name                = "${var.module_wide_prefix_scope}-webserver-healthcheck"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = local.webapp_webserver_port
  }
}

// TODO - RegMIG --- //
resource "google_compute_region_instance_group_manager" "regmig_webserver" {
  count = length(var.webserver_deployment_regions)

  provider           = google-beta
  name               = "${var.module_wide_prefix_scope}-${count.index}-regmig-webserver"
  region             = var.webserver_deployment_regions[count.index]
  base_instance_name = "${var.module_wide_prefix_scope}-${count.index}-webserver"
  depends_on = [
    google_compute_instance_template.webserver_template,
    google_compute_firewall.vpc_netfw_webserver_node,
    null_resource.webapp_provisioner
  ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.webserver_template[count.index].id
  }

  target_size = var.deployment_target_size

  named_port {
    name = local.webapp_webserver_port_name
    port = local.webapp_webserver_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.webserver_healthcheck.id
    initial_delay_sec = 20
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

// TODO - Autoscalers --- //
resource "google_compute_region_autoscaler" "autoscaler_webserver" {
  count = length(var.webserver_deployment_regions)

  name   = "${var.module_wide_prefix_scope}-${count.index}-autoscaler"
  region = var.webserver_deployment_regions[count.index]
  target = google_compute_region_instance_group_manager.regmig_webserver[count.index].id

  autoscaling_policy {
    max_replicas    = length(data.google_compute_zones.available[count.index].names) * 2
    min_replicas    = 1
    cooldown_period = 30
    load_balancing_utilization {
      target = 0.5
    }
    cpu_utilization {
      target = 0.75
    }
  }
}
