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
}

