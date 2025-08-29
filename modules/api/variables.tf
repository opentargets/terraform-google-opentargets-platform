// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for resources names deployed by this module, default 'otpdevapi'"
  type        = string
  default     = "otpdevapi"
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

// --- API Instances configuration --- //
variable "deployment_regions" {
  description = "List of regions where the API nodes should be deployed"
  type        = list(string)
}

variable "vm_firewall_tags" {
  description = "List of additional tags to attach to API nodes"
  type        = list(string)
  default     = []
}

variable "vm_platform_api_image_version" {
  description = "API Docker image version to use in deployment"
  type        = string
}

variable "vm_api_vcpus" {
  description = "CPU count for API nodes, default '2'"
  type        = number
  default     = "2"
}

variable "vm_api_mem" {
  description = "Amount of memory allocated for API nodes (MiB), default '7680'"
  type        = number
  default     = "7680"
}

variable "jvm_xms" {
  description = "JVM initial heap size, default '2g'"
  type        = string
  default     = "2g"
}

variable "jvm_xmx" {
  description = "JVM maximum heap size, default '7g'"
  type        = string
  default     = "7g"
}

variable "vm_api_image" {
  description = "VM image to use for API nodes, default 'cos-stable'"
  type        = string
  default     = "cos-stable"
}

variable "vm_api_image_project" {
  description = "Project hosting the VM image, default 'cos-cloud'"
  type        = string
  default     = "cos-cloud"
}

variable "vm_api_boot_disk_size" {
  description = "Boot disk size for API nodes, default '10GB'"
  type        = string
  default     = "10GB"
}

variable "vm_flag_preemptible" {
  description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
  type        = bool
  default     = false
}

variable "deployment_target_size" {
  description = "Initial API node count per region"
  type        = number
  default     = 1
}

// --- API metadata --- //
variable "api_v_major" {
  description = "Major API Version"
  type        = string
}
variable "api_v_minor" {
  description = "Minor API Version"
  type        = string
}
variable "api_v_patch" {
  description = "Patch API Version"
  type        = string
}
variable "api_d_year" {
  description = "API data - year"
  type        = string
}
variable "api_d_month" {
  description = "API data - month"
  type        = string
}
variable "api_d_iteration" {
  description = "API data - iteration"
  type        = string
}
variable "api_ignore_cache" {
  description = "Disable API caching"
  type        = bool
  default     = false
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

// --- DNS configuration --- //
variable "dns_domain_api" {
  description = "This is the baseline DNS to use for all the forwarding rules that will be configured in the GLB, if chosen"
  type        = string
}

variable "node_exporter_image_name" {
  description = "Image used to create the node exporter container."
  default     = "quay.io/prometheus/node-exporter"
}

variable "node_exporter_image_version" {
  description = "Image version of the node exporter image."
  default     = "v1.9.1"
}
