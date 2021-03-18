// --- Web Application Module Input Parameters --- //
// General Deployment Information --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for naming resources in this deployment, default 'otpdevwebapp'"
  default = "otpdevwebapp"
}

variable "project_id" {
  description = "Project ID where resources will be deployed"
}

variable "location" {
  description = "This input value sets the bucket's location. Multi-Region or Regional buckets location values are supported, see https://cloud.google.com/storage/docs/locations#location-mr for more information. By default, the bucket is regional, location 'EUROPE-WEST4'"
  default = "EUROPE-WEST4"
}

// --- Web APP Configuration --- //
variable "webapp_repo_name" {
  description = "Web Application repository name"
}

variable "webapp_release" {
  description = "Release version of the web application to deploy"
}

variable "webapp_deployment_context_placeholder" {
  description = "This defines the placeholder to replace within the public index.html, with the deployment context, default 'DEVOPS_CONTEXT_DEPLOYMENT' (DEPRECATED)"
  default = "DEVOPS_CONTEXT_DEPLOYMENT"
}

variable "webapp_deployment_context" {
  description = "Values for parameterising the deployment of the web application, see defaults as an example"
  default = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT = "undefined"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT_BETA = "undefined"
  }
}

variable "webapp_docker_node_version" {
  description = "Node version to use for building the bundle"
  default = 12
}

variable "website_not_found_page" {
  description = "It defines the website 'not found' page"
  default = "index.html"
}

