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

