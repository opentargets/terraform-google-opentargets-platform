// Elastic Search Deployment
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a Regional Elasctic Search deployment behind a ILB
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
    elastic_search_template_machine_type = local.elastic_search_template_machine_type,
    elastic_search_template_source_image = local.elastic_search_template_source_image,
    elastic_search_template_tags = join("", sort(local.elastic_search_template_tags)),
    vm_elastic_search_version = var.vm_elastic_search_version
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

resource "google_compute_instance_template" "elastic_search_template" {
  name = "${var.module_wide_prefix_scope}-elastic-search-template-${random_string.random.result}"
  description = "Open Targets Platform Elastic Search node template, release ${var.vm_elastic_search_image}"
  instance_description = "Open Targets Platform Elastic Search node - release ${var.vm_elastic_search_image}"
  region = var.deployment_region
    
  tags = local.elastic_search_template_tags

  machine_type = local.elastic_search_template_machine_type
  can_ip_forward = false

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = local.elastic_search_template_source_image
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
        ELASTIC_SEARCH_VERSION = var.vm_elastic_search_version
      }
    )
    google-logging-enabled = true
  }

  service_account {
    email = google_service_account.gcp_service_acc_apis.email
    scopes = [ "cloud-platform" ]
  }
}

// --- Health Check for instance group --- //
resource "google_compute_health_check" "elastic_search_healthcheck" {
  name = "${var.module_wide_prefix_scope}-elastic-search-healthcheck"
  check_interval_sec = 5
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 10

  tcp_health_check {
    // Elastic Search Requests Port
    port = local.elastic_search_port_requests
  }
}

// --- Regional Instance Group Manager --- //
resource "google_compute_region_instance_group_manager" "regmig_elastic_search" {
  name = "${var.module_wide_prefix_scope}-regmig-elastic-search"
  region = var.deployment_region
  base_instance_name = "${var.module_wide_prefix_scope}-esearch"
  depends_on = [ 
      google_compute_instance_template.elastic_search_template,
      google_compute_firewall.vpc_netfw_elasticsearch_requests,
      google_compute_firewall.vpc_netfw_elasticsearch_comms
    ]

  // Instance Template
  version {
    instance_template = google_compute_instance_template.elastic_search_template.id
  }

  //target_size = var.deployment_target_size

  named_port {
    name = local.elastic_search_port_requests_name
    port = local.elastic_search_port_requests
  }

  named_port {
    name = local.elastic_search_port_comms_name
    port = local.elastic_search_port_comms
  }

  auto_healing_policies {
    health_check = google_compute_health_check.elastic_search_healthcheck.id
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = local.compute_zones_n_total
    max_unavailable_fixed        = 0
    min_ready_sec                = 30
  }
}

// --- AUTOSCALERS --- //
resource "google_compute_region_autoscaler" "autoscaler_elastic_search" {
  name = "${var.module_wide_prefix_scope}-autoscaler"
  region = var.deployment_region
  target = google_compute_region_instance_group_manager.regmig_elastic_search.id

  autoscaling_policy {
    max_replicas = local.compute_zones_n_total * 2
    min_replicas = 1
    cooldown_period = 60
    cpu_utilization {
      target = 0.75
    }
  }
}
