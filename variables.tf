// --- RELEASE INFORMATION --- //
variable "config_release_name" {
  description = "Open Targets Platform release name, not related to any configuration parameter."
  type = string
}

// --- DEPLOYMENT CONFIGURATION --- //
// Terraform Backend Configuration --- //
variable "config_tf_backend_bucket_name" {
  description = "Google Cloud Bucket where Terraform State is stored, default is 'none'"
  type = string
  default = "none"
}

variable "config_tf_backend_prefix" {
  description = "Prefix for Terraformt State stored in the configured backend bucket, default is 'none'"
  type = string
  default = "none"
}

variable "config_gcp_default_region" {
  description = "Default region when not specified in the module"
  type = string
}

variable "config_gcp_default_zone" {
  description = "Default zone when not specified in the module"
  type = string
}

variable "config_project_id" {
  description = "Default project to use when not specified in the module"
  type = string
}

variable "config_deployment_regions" {
  description = "A list of regions where to deploy the OT Platform"
  type = list(string)
}

// --- Elastic Search Configuration --- //
variable "config_vm_elastic_search_image_project" {
  description = "This allows to specify a different than deployment project for the deployed Elastic Search Instance image to be used."
  type = string
}

variable "config_vm_elastic_search_vcpus" {
  description = "CPU count configuration for the deployed Elastic Search Instances"
  type = number
}

variable "config_vm_elastic_search_mem" {
  description = "RAM configuration for the deployed Elastic Search Instances"
  type = number
}

variable "config_vm_elastic_search_image" {
  description = "Disk image to use for the deployed Elastic Search Instances"
  type = string
}

variable "config_vm_elastic_search_version" {
  description = "Elastic search version to deploy"
  type = string
}

variable "config_vm_elastic_search_boot_disk_size" {
  description = "Boot disk size to use for the deployed Elastic Search Instances"
  type = string
}

// --- Clickhouse configuration --- //
variable "config_vm_clickhouse_vcpus" {
  description = "CPU count for Clickhouse instances"
  type = number
}

variable "config_vm_clickhouse_mem" {
  description = "Amount of memory allocated for Clickhouse instances"
  type = number
}

variable "config_vm_clickhouse_image" {
  description = "Image to use for launching Clickhouse instances"
  type = string
}

variable "config_vm_clickhouse_image_project" {
  description = "Project where to find the instance image to use"
  type = string
}

variable "config_vm_clickhouse_boot_disk_size" {
  description = "Boot disk size to be used in Clickhouse instances"
  type = string
}

// --- API Configuration --- //
variable "config_vm_platform_api_image_version" {
  description = "Platform API docker image version to use"
  type = string
}
variable "config_vm_api_vcpus" {
  description = "CPU count for API nodes"
  type = number
}
variable "config_vm_api_mem" {
  description = "Memory allocation for API VMs (MiB)"
  type = number
}
variable "config_vm_api_image" {
  description = "VM image to use for running API nodes"
  type = string
}
variable "config_vm_api_image_project" {
  description = "Project hosting the API VM image"
  type = string
}
variable "config_vm_api_boot_disk_size" {
  description = "Boot disk size for API VM nodes"
  type = string
}

// --- DNS Configuration --- //
variable "config_dns_project_id" {
  description = "Project ID to use when making changes to Cloud DNS service"
  type = string
}

variable "config_dns_subdomain_prefix" {
  description = "DNS subdomain prefix to use for anything this deployment definition adds to the DNS information"
  default = null
}

variable "config_dns_managed_zone_name" {
  description = "Name of the Cloud DNS managed zone to use for DNS changes"
  type = string
}

variable "config_dns_managed_zone_dns_name" {
  description = "Domain name that is being managed in the given managed DNS zone, a.k.a. Cloud DNS -> Managed Zone -> DNS Name"
  type = string
}

variable "config_dns_platform_api_subdomain" {
  description = "Subdomain for platform API DNS entry, default 'api'"
  type = string
  default = "api"
}

variable "config_dns_platform_subdomain" {
  description = "Subdomain for Open Targets Platform Web App, default 'platform'"
  type = string
  default = "platform"
}

// --- WEB APP Configuration --- //
variable "config_webapp_repo_name" {
  description = "Web Application repository name"
  type = string
}

variable "config_webapp_release" {
  description = "Release version of the web application to deploy"
  type = string
}

variable "config_webapp_deployment_context_map" {
  description = "A map with values for those parameters that need to be customized in the deployment of the web application, see module defaults as an example"
  // In this iteration, we use 'any' type here, while we converge on the mapping model for the web application
  type = any
}

variable "config_webapp_location" {
  description = "This input parameter defines the location of the Web Application (bucket), default 'EU'"
  type = string
  default = "EU"
}

variable "config_webapp_robots_profile" {
  description = "This input parameter defines the 'robots.txt' profile to be used when deploying the web application, default 'default', which means that no changes to existing 'robots.txt' file will be made"
  type = string
  default = "default"
}

// --- Development --- //
variable "config_set_dev_mode_on" {
  description = "If 'true', it will set the deployment to 'development mode', default is 'false'"
  default = false
}

variable "config_enable_inspection" {
  description = "If 'true', it will deploy additional VMs for infrastructure inspection, 'false'"
  default = false
}