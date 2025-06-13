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
  description = "Open Targets Platform release name, not related to any configuration parameter."
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

variable "network_sources_health_checks" {
  description = "Source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]'"
  default = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
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

variable "vm_prometheus_vcpus" {
  description = "CPU count for prometheus nodes, default '2'"
  type        = number
  default     = "2"
}

variable "vm_prometheus_mem" {
  description = "Amount of memory allocated for prometheus nodes (MiB), default '7680'"
  type        = number
  default     = "7680"
}

variable "vm_prometheus_image" {
  description = "VM image to use for prometheus nodes, default 'cos-stable'"
  type        = string
  default     = "projects/debian-cloud/global/images/debian-12-bookworm-v20250415"
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

// --- Backend Connection Information --- //
variable "backend_connection_map" {
  description = "Information on where to connect to data backend services"
  // This iteration won't check the type, this definition will be refined in future iterations
  type = any
  /*
  {
    "region" = {
      "host_clickhouse" = "127.0.0.0",
      "host_elastic_search" = "127.0.0.0"
    }
  }
  */
}

// --- Load Balancer configuration --- //
variable "load_balancer_type" {
  description = "This will tell the module whether an ILB, GLB or no load balancer at all should be created"
  type        = string
  validation {
    condition     = contains(["INTERNAL", "GLOBAL", "NONE"], var.load_balancer_type)
    error_message = "Allowed values for 'load_balancer_type' are [ 'INTERNAL', 'GLOBAL', 'NONE' ]."
  }
}

variable "git_branch" {
  description = "value"
  default     = "main"
}

variable "git_repository" {
  description = "value"
  default     = "https://github.com/opentargets/terraform-google-opentargets-platform.git"
}
