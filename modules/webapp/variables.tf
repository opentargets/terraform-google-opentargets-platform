// --- Web Application Module Input Parameters --- //
// General Deployment Information --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for naming resources in this deployment, default 'otpdevwebapp'"
  type = string
  default = "otpdevwebapp"
}

variable "project_id" {
  description = "Project ID where resources will be deployed"
  type = string
}

variable "location" {
  description = "This input value sets the bucket's location. Multi-Region or Regional buckets location values are supported, see https://cloud.google.com/storage/docs/locations#location-mr for more information. By default, the bucket is regional, location 'EUROPE-WEST4'"
  type = string
  default = "EUROPE-WEST4"
}

// --- Web APP Configuration --- //
variable "webapp_repo_name" {
  description = "Web Application repository name"
  type = string
}

variable "webapp_release" {
  description = "Release version of the web application to deploy"
  type = string
}

variable "webapp_deployment_context_placeholder" {
  description = "This defines the placeholder to replace within the public index.html, with the deployment context, default 'DEVOPS_CONTEXT_DEPLOYMENT' (DEPRECATED)"
  type = string
  default = "DEVOPS_CONTEXT_DEPLOYMENT"
}

variable "webapp_deployment_context" {
  description = "Values for parameterising the deployment of the web application, see defaults as an example"
  // This iteration won't check the type, waiting for the frontend contract to converge on this
  type = any
  default = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT = "undefined"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT_BETA = "undefined"
  }
}

variable "webapp_robots_profile" {
  description = "This defines which 'robots.txt' profile to deploy with the web application, default is 'default', which means no changes will be made to the main 'robots.txt' file set in the web application bundle"
  type = string
  default = "default"
}

variable "webapp_bucket_data_context_name" {
  description = "Bucket name where to find the web application data context"
  type = string
}

variable "webapp_bucket_data_context_release" {
  description = "Web application data context release to use for deployment"
  type = string
}

variable "webapp_bucket_data_context_subfolder_name" {
  description = "Name of the subfolder within the data context release where to find the data static assets"
  type = string
  default = "webapp"
}

variable "webapp_docker_node_version" {
  description = "Node version to use for building the bundle"
  type = number
  default = 12
}

variable "website_not_found_page" {
  description = "It defines the website 'not found' page, default 'index.html'"
  type = string
  default = "index.html"
}

// --- Web Servers Configuration --- //


// --- Temporary assets --- //
variable "folder_tmp" {
  description = "Path to a temporary folder where to deploy working directories"
  type = string
}
