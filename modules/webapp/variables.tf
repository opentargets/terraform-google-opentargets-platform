// --- Web Application Module Input Parameters --- //
// General Deployment Information --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for naming resources in this deployment, default 'otpdevwebapp'"
  type        = string
  default     = "otpdevwebapp"
}

variable "project_id" {
  description = "Project ID where resources will be deployed"
  type        = string
}

variable "location" {
  description = "This input value sets the bucket's location. Multi-Region or Regional buckets location values are supported, see https://cloud.google.com/storage/docs/locations#location-mr for more information. By default, the bucket is regional, location 'EUROPE-WEST4'"
  type        = string
  default     = "europe-west1"
}

// --- Web APP Configuration --- //
variable "webapp_repo_name" {
  description = "Web Application repository name"
  type        = string
}

variable "webapp_release" {
  description = "Release version of the web application to deploy"
  type        = string
}

variable "webapp_image_version" {
  description = "Webapp image tag to use for the web application deployment"
  type        = string
}

variable "webapp_deployment_context_placeholder" {
  description = "This defines the placeholder to replace within the public index.html, with the deployment context, default 'DEVOPS_CONTEXT_DEPLOYMENT' (DEPRECATED)"
  type        = string
  default     = "DEVOPS_CONTEXT_DEPLOYMENT"
}

variable "webapp_deployment_context_env" {
  description = "This defines the environment variable to use for the deployment context"
  type        = any
}

variable "webapp_deployment_context" {
  description = "Values for parameterising the deployment of the web application, see defaults as an example"
  // This iteration won't check the type, waiting for the frontend contract to converge on this
  type = any
  default = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT      = "undefined"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT_BETA = "undefined"
  }
}

variable "webapp_robots_profile" {
  description = "This defines which 'robots.txt' profile to deploy with the web application, default is 'default', which means no changes will be made to the main 'robots.txt' file set in the web application bundle"
  type        = string
  default     = "default"
}

variable "webapp_custom_profile" {
  description = "Web application customisation profile to use, default 'default.js'"
  type        = string
  default     = "default.js"
}

variable "webapp_bucket_data_context_name" {
  description = "Bucket name where to find the web application data context"
  type        = string
}

variable "webapp_bucket_data_context_release" {
  description = "Web application data context release to use for deployment"
  type        = string
}

variable "webapp_bucket_data_context_subfolder_name" {
  description = "Name of the subfolder within the data context release where to find the data static assets"
  type        = string
  default     = "webapp"
}

variable "webapp_sitemaps_repo_name" {
  description = "Name of the GitHub repository where to find the software that generates the sitemaps for the web application"
  type        = string
}

variable "webapp_sitemaps_release" {
  description = "Sitemaps script release to use"
  type        = string
}

variable "webapp_sitemaps_bigquery_table" {
  description = "BigQuery table to pull the sitemaps data from"
  type        = string
}

variable "webapp_sitemaps_bigquery_project" {
  description = "Project hosting the BigQuery services"
  type        = string
}


variable "webapp_docker_node_version" {
  description = "Node version to use for building the bundle"
  type        = number
  default     = 12
}

variable "website_not_found_page" {
  description = "It defines the website 'not found' page, default 'index.html'"
  type        = string
  default     = "index.html"
}

// --- Web Servers Configuration --- //
// Networking --- //
variable "network_name" {
  description = "Name of the network where resources should be connected to, default 'default'"
  type        = string
  default     = "default"
}

variable "network_self_link" {
  description = "Self link to the network where resources should be connected when deployed"
  type        = string
  default     = "default"
}

variable "network_subnet_name" {
  description = "Name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'"
  type        = string
  default     = "main-subnet"
}

variable "network_source_ranges_map" {
  description = "CIDR that represents which IPs we want to grant access to the deployed resources"
  // This iteration won't check the type, this definition will be refined in future iterations
  type = any
  /*[
    region = {
      subnet_ip = "CIDR"
    }
  ]
 */
}

variable "network_sources_health_checks" {
  description = "Source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]'"
  default = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}
// Compute Instances (VMs) --- //
variable "webserver_deployment_regions" {
  description = "List of regions where to deploy the web servers"
  type        = list(string)
}

variable "webserver_firewall_tags" {
  description = "List of additional tags to attach to API nodes"
  type        = list(string)
  default     = []
}

variable "webserver_docker_image_version" {
  description = "NginX Docker image version to use in deployment"
  type        = string
}

variable "webserver_vm_vcpus" {
  description = "CPU count, default '1'"
  type        = number
  default     = "1"
}

variable "webserver_vm_mem" {
  description = "Amount of memory allocated Web Server nodes (MiB), default '3840'"
  type        = number
  default     = "3840"
}

variable "webserver_vm_image" {
  description = "VM image to use for Web Server nodes, default 'debian-12'"
  type        = string
  default     = "debian-12"
}

variable "webserver_vm_image_project" {
  description = "Project hosting the VM image, default 'debian-cloud'"
  type        = string
  default     = "debian-cloud"
}

variable "webserver_vm_boot_disk_size" {
  description = "Boot disk size for Web Server nodes, default '10GB'"
  type        = string
  default     = "10GB"
}

variable "vm_flag_preemptible" {
  description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
  type        = bool
  default     = false
}

variable "deployment_target_size" {
  description = "Initial Web Server instance count per region"
  type        = number
  default     = 1
}

// --- Temporary assets --- //
variable "folder_tmp" {
  description = "Path to a temporary folder where to deploy working directories"
  type        = string
}
