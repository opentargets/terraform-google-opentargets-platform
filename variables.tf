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

variable "config_project_id" {
  description = "Default project to use when not specified in the module"
}

variable "config_deployment_regions" {
  description = "A list of regions where to deploy the OT Platform"
}

// --- ELASTIC SEARCH CONFIGURATION --- //
variable "config_vm_elastic_search_image_project" {
  description = "This allows to specify a different than deployment project for the deployed Elastic Search Instance image to be used."
}

variable "config_vm_elastic_search_vcpus" {
  description = "CPU count configuration for the deployed Elastic Search Instances"
}

variable "config_vm_elastic_search_mem" {
  description = "RAM configuration for the deployed Elastic Search Instances"
}

variable "config_vm_elastic_search_image" {
  description = "Disk image to use for the deployed Elastic Search Instances"
}

variable "config_vm_elastic_search_version" {
  description = "Elastic search version to deploy"
}

variable "config_vm_elastic_search_boot_disk_size" {
  description = "Boot disk size to use for the deployed Elastic Search Instances"
}

// --- Clickhouse configuration --- //
variable "config_vm_clickhouse_vcpus" {
  description = "CPU count for Clickhouse instances"
}

variable "config_vm_clickhouse_mem" {
  description = "Amount of memory allocated for Clickhouse instances"
}

variable "config_vm_clickhouse_image" {
  description = "Image to use for launching Clickhouse instances"
}

variable "config_vm_clickhouse_image_project" {
  description = "Project where to find the instance image to use"
}

variable "config_vm_clickhouse_boot_disk_size" {
  description = "Boot disk size to be used in Clickhouse instances"
}

// --- DNS Configuration --- //
variable "config_dns_project_id" {
  description = "Project ID to use when making changes to Cloud DNS service"
  // TODO validation mechanism
}

variable "config_dns_subdomain_prefix" {
  description = "DNS subdomain prefix to use for anything this deployment definition adds to the DNS information"
  default = null
  // TODO validation mechanism
}

variable "config_dns_managed_zone_name" {
  description = "Name of the Cloud DNS managed zone to use for DNS changes"
  // TODO validation mechanism
}

variable "config_dns_managed_zone_dns_name" {
  description = "Domain name that is being managed in the given managed DNS zone, a.k.a. Cloud DNS -> Managed Zone -> DNS Name"
  // TODO validation mechanism
}

