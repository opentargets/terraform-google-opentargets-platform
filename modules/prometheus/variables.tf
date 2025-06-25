// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for resources names deployed by this module, default 'otpdevprometheus'"
  type        = string
  default     = "otpdevprometheus"
}

variable "module_wide_prefix_es" {
  description = "Scoping prefix for resources from elastisearch module"
  type        = string
}

variable "module_wide_prefix_ch" {
  description = "Scoping prefix for resources from clickhouse module"
  type        = string
}

variable "module_wide_prefix_api" {
  description = "Scoping prefix for resources from api module"
  type        = string
}

variable "config_release_name" {
  description = "Open Targets Platform release name. Used to filter to select only the resources related to the specific release."
  type        = string
}

variable "project_id" {
  description = "Project ID where to deploy resources"
  type        = string
}

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

// --- prometheus Instances configuration --- //
variable "deployment_regions" {
  description = "List of regions where the prometheus nodes should be deployed"
  type        = list(string)
}

variable "vm_firewall_tags" {
  description = "List of additional tags to attach to prometheus nodes"
  type        = list(string)
  default     = []
}

variable "vm_prometheus_type" {
  description = "Machine type to use for the OpenAI API deployment, default 'n1-standard-1'"
  type        = string
  default     = "n1-standard-1"
}

variable "vm_prometheus_image" {
  description = "VM image to use for prometheus nodes, default 'cos-stable'"
  type        = string
  default     = "debian-12"
}

variable "vm_prometheus_image_project" {
  description = "Project hosting the VM image, default 'debian-cloud'"
  type        = string
  default     = "debian-cloud"
}

variable "vm_prometheus_boot_disk_size" {
  description = "Boot disk size for prometheus nodes, default '10GB'"
  type        = string
  default     = "50GB"
}

variable "vm_flag_preemptible" {
  description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
  type        = bool
  default     = false
}

variable "deployment_target_size" {
  description = "Initial prometheus node count per region"
  type        = number
  default     = 1
}

variable "common_tags" {
  description = "List of common tags to attach to resources"
  type        = list(string)
}

// --- Git Repository --- //
variable "git_branch" {
  description = "Git branch in which the resources will be available."
  default     = "main"
}

variable "git_repository" {
  description = "Git repository that stores the Prometheus and Grafana module."
  default     = "https://github.com/opentargets/terraform-google-opentargets-platform.git"
}

// --- Docker configurations --- //
variable "prometheus_image_name" {
  description = "Image used to create the prometheus container."
  default     = "prom/prometheus"
}

variable "prometheus_image_version" {
  description = "Image version of the prometheus image."
  default     = "latest"
}

variable "prometheus_container_port" {
  description = "Port number that will be exposed in the prometheus container."
  default     = 9090
}

variable "grafana_image_name" {
  description = "Image used to create the prometheus container."
  default     = "grafana/grafana"
}

variable "grafana_image_version" {
  description = "Image version of the prometheus image."
  default     = "latest"
}

variable "grafana_container_port" {
  description = "Port number that will be exposed in the grafnaa container."
  default     = 3000
}

variable "node_exporter_image_name" {
  description = "Image used to create the node exporter container."
  default     = "quay.io/prometheus/node-exporter"
}

variable "node_exporter_image_version" {
  description = "Image version of the node exporter image."
  default     = "latest"
}
