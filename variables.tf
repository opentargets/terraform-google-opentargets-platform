// --- RELEASE INFORMATION --- //
variable "config_release_name" {
  description = "Open Targets Platform release name, not related to any configuration parameter."
  type        = string
}

// --- DEPLOYMENT CONFIGURATION --- //
// Terraform Backend Configuration --- //
variable "config_tf_backend_bucket_name" {
  description = "Google Cloud Bucket where Terraform State is stored, default is 'none'"
  type        = string
  default     = "none"
}

variable "config_tf_backend_prefix" {
  description = "Prefix for Terraformt State stored in the configured backend bucket, default is 'none'"
  type        = string
  default     = "none"
}

variable "config_gcp_default_region" {
  description = "Default region when not specified in the module"
  type        = string
}

variable "config_gcp_default_zone" {
  description = "Default zone when not specified in the module"
  type        = string
}

variable "config_project_id" {
  description = "Default project to use when not specified in the module"
  type        = string
}

variable "config_deployment_regions" {
  description = "A list of regions where to deploy the OT Platform"
  type        = list(string)
}

// --- Elastic Search Configuration --- //
variable "config_vm_elastic_search_image_project" {
  description = "This allows to specify a different than deployment project for the deployed Elastic Search Instance image to be used."
  type        = string
  default     = "cos-stable"
}

variable "config_vm_elastic_search_vcpus" {
  description = "CPU count configuration for the deployed Elastic Search Instances, default '6'"
  type        = number
  default     = "6"
}

variable "config_vm_elastic_search_mem" {
  description = "RAM configuration for the deployed Elastic Search Instances"
  type        = number
  default     = "39936"
}

variable "config_vm_elastic_search_image" {
  description = "Disk image to use for the deployed Elastic Search Instances"
  type        = string
  default     = "cos-cloud"
}

variable "config_vm_elastic_search_version" {
  description = "Elastic search version to deploy"
  type        = string
}

variable "config_vm_elastic_search_boot_disk_size" {
  description = "Boot disk size to use for the deployed Elastic Search Instances"
  type        = string
  default     = "16GB"
}

variable "config_vm_elasticsearch_flag_preemptible" {
  description = "Use this flag for deploying Elastic Search nodes on preemptible VMs, default 'false'"
  type        = bool
  default     = false
}

// --- Clickhouse configuration --- //
variable "config_vm_clickhouse_vcpus" {
  description = "CPU count for Clickhouse instances, default '4'"
  type        = number
  default     = "4"
}

variable "config_vm_clickhouse_mem" {
  description = "Amount of memory allocated for Clickhouse instances, default '26624'"
  type        = number
  default     = "26624"
}

variable "config_vm_clickhouse_image" {
  description = "Image to use for launching Clickhouse instances"
  type        = string
  default     = "cos-stable"
}

variable "config_vm_clickhouse_image_project" {
  description = "Project where to find the instance image to use"
  type        = string
  default     = "cos-cloud"
}

variable "config_vm_clickhouse_flag_preemptible" {
  description = "Use this flag for deploying Clickhouse nodes on preemptible VMs, default 'false'"
  type        = bool
  default     = false
}

variable "config_vm_clickhouse_boot_disk_size" {
  description = "Boot disk size to be used in Clickhouse instances"
  type        = string
  default     = "16GB"
}

// --- API Configuration --- //
variable "config_vm_platform_api_image_version" {
  description = "Platform API docker image version to use"
  type        = string
}
variable "config_vm_api_vcpus" {
  description = "CPU count for API nodes, default '2'"
  type        = number
  default     = "2"
}
variable "config_vm_api_mem" {
  description = "Memory allocation for API VMs (MiB)"
  type        = number
  default     = "7680"
}
variable "config_vm_api_image" {
  description = "VM image to use for running API nodes"
  type        = string
  default     = "cos-stable"
}
variable "config_vm_api_image_project" {
  description = "Project hosting the API VM image"
  type        = string
  default     = "cos-cloud"
}
variable "config_vm_api_boot_disk_size" {
  description = "Boot disk size for API VM nodes"
  type        = string
  default     = "10GB"
}

variable "config_vm_api_flag_preemptible" {
  description = "Use this flag for deploying API nodes on preemptible VMs, default 'false'"
  type        = bool
  default     = false
}

// --- DNS Configuration --- //
variable "config_dns_project_id" {
  description = "Project ID to use when making changes to Cloud DNS service"
  type        = string
}

variable "config_dns_subdomain_prefix" {
  description = "DNS subdomain prefix to use for anything this deployment definition adds to the DNS information"
  default     = null
}

variable "config_dns_managed_zone_name" {
  description = "Name of the Cloud DNS managed zone to use for DNS changes"
  type        = string
}

variable "config_dns_managed_zone_dns_name" {
  description = "Domain name that is being managed in the given managed DNS zone, a.k.a. Cloud DNS -> Managed Zone -> DNS Name"
  type        = string
}

variable "config_dns_platform_api_subdomain" {
  description = "Subdomain for platform API DNS entry, default 'api'"
  type        = string
  default     = "api"
}

variable "config_dns_platform_subdomain" {
  description = "Subdomain for Open Targets Platform Web App, default 'platform'"
  type        = string
  default     = "platform"
}

// --- WEB APP Configuration --- //
variable "config_webapp_repo_name" {
  description = "Web Application repository name"
  type        = string
}

variable "config_webapp_release" {
  description = "Release version of the web application to deploy"
  type        = string
}

variable "config_webapp_deployment_context_map" {
  description = "A map with values for those parameters that need to be customized in the deployment of the web application, see module defaults as an example"
  // In this iteration, we use 'any' type here, while we converge on the mapping model for the web application
  type = any
}

variable "config_webapp_location" {
  description = "This input parameter defines the location of the Web Application (bucket), default 'EU'"
  type        = string
  default     = "EU"
}

variable "config_webapp_robots_profile" {
  description = "This input parameter defines the 'robots.txt' profile to be used when deploying the web application, default 'default', which means that no changes to existing 'robots.txt' file will be made"
  type        = string
  default     = "default"
}

variable "config_webapp_custom_profile" {
  description = "Web application customisation profile to use, if not provided, the default set by the web app module will be used"
  type        = string
  default     = "default.js"
}

variable "config_webapp_bucket_name_data_assets" {
  description = "Bucket where to find the data context for the web application"
  type        = string
}

variable "config_webapp_data_context_release" {
  description = "Data context release for the web application"
  type        = string
}

variable "config_webapp_sitemaps_repo_name" {
  description = "Name of the GitHub repository where to find the software that generates the sitemaps for the web application"
  type        = string
}

variable "config_webapp_sitemaps_release" {
  description = "Sitemaps script release to use"
  type        = string
}

variable "config_webapp_sitemaps_bigquery_table" {
  description = "BigQuery table to pull the sitemaps data from"
  type        = string
}

variable "config_webapp_sitemaps_bigquery_project" {
  description = "Project hosting the BigQuery services"
  type        = string
}

// Web Application Web Servers --- //
variable "config_webapp_webserver_docker_image_version" {
  description = "NginX Docker image version to use in deployment"
  type        = string
}

variable "config_webapp_webserver_vm_vcpus" {
  description = "CPU count, default '1'"
  type        = number
  default     = "1"
}

variable "config_webapp_webserver_vm_mem" {
  description = "Amount of memory allocated Web Server nodes (MiB), default '3840'"
  type        = number
  default     = "3840"
}

variable "config_webapp_webserver_vm_image" {
  description = "VM image to use for Web Server nodes, default 'cos-stable'"
  type        = string
  default     = "cos-stable"
}

variable "config_webapp_webserver_vm_image_project" {
  description = "Project hosting the VM image, default 'cos-cloud'"
  type        = string
  default     = "cos-cloud"
}

variable "config_webapp_webserver_vm_boot_disk_size" {
  description = "Boot disk size for Web Server nodes, default '10GB'"
  type        = string
  default     = "10GB"
}

variable "config_vm_webserver_flag_preemptible" {
  description = "Use this flag for deploying Web nodes on preemptible VMs, default 'false'"
  type        = bool
  default     = false
}


// --- Global Load Balancer --- //
variable "config_glb_webapp_enable_cdn" {
  description = "This parameters indicates the GLB whether we want to use a CDN or not, default 'true'"
  default     = true
}

// --- Network Security --- //
variable "config_security_api_enable" {
  description = "Enable security policies for the platform API, default 'false'"
  default     = false
}

variable "config_security_webapp_enable" {
  description = "Enable security policies for the web application, default 'false'"
  default     = false
}

variable "config_security_restrict_source_ips_cidrs_file" {
  description = "Text file within the 'profiles' folder that contains the list of CIDRs allowed to access the platform"
  type        = string
  default     = "netsec_cidr.default"
}
// --- Development --- //
variable "config_set_dev_mode_on" {
  description = "If 'true', it will set the deployment to 'development mode', default is 'false'"
  default     = false
}

variable "config_enable_inspection" {
  description = "If 'true', it will deploy additional VMs for infrastructure inspection, 'false'"
  default     = false
}


// --- API metadata --- //
variable "config_vm_version_major" {
  description = "Major API Version"
  type        = string
  default     = "0"
}
variable "config_vm_version_minor" {
  description = "Minor API Version"
  type        = string
  default     = "0"
}
variable "config_vm_version_patch" {
  description = "Patch API Version"
  type        = string
  default     = "0"
}
variable "config_vm_data_year" {
  description = "API data - year"
  type        = string
  default     = "0"
}
variable "config_vm_data_month" {
  description = "API data - month"
  type        = string
  default     = "0"
}
variable "config_vm_data_iteration" {
  description = "API data - iteration"
  type        = string
  default     = "0"
}
