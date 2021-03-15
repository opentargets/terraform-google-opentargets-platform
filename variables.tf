// --- RELEASE INFORMATION --- //
variable "config_release_name" {
  description = "Open Targets Platform release name, not related to any configuration parameter."
}

// --- DEPLOYMENT CONFIGURATION --- //
variable "config_gcp_default_region" {
  description = "Default region when not specified in the module"
}

variable "config_gcp_default_zone" {
  description = "Default zone when not specified in the module"
}

