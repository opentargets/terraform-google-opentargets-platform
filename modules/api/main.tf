// Open Targets Platform API deployment definition
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a multi-regional deployment of Open Target Platform API
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
    otpapi_template_tags = join("", sort(local.otpapi_template_tags)),
    otpapi_template_machine_type = local.otpapi_template_machine_type,
    otpapi_template_source_image = local.otpapi_template_source_image,
    vm_platform_api_image_version = var.vm_platform_api_image_version
  }
}

