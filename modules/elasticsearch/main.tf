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
  }
}

