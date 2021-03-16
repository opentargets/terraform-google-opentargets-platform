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

