// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "The prefix provided here will scope names for those resources created by this module, default 'otpdevch'"
  type        = string
  default     = "otpdevch"
}

variable "project_id" {
  description = "Project ID where to deploy resources"
  type        = string
}

variable "network_name" {
  description = "Name of the network resources will be connected to, default 'default'"
  type        = string
  default     = "default"
}

variable "network_self_link" {
  description = "Self link to the network where resources should be connected when deployed, default 'default'"
  type        = string
  default     = "default"
}

variable "network_subnet_name" {
  description = "Name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'"
  type        = string
  default     = "main-subnet"
}

variable "network_source_ranges" {
  description = "CIDR that represents which IPs we want to grant access to the deployed resources, default '10.0.0.0/9'"
  type        = list(string)
  default     = ["10.0.0.0/9"]
}

variable "network_sources_health_checks" {
  description = "Source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]'"
  default = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

variable "deployment_region" {
  description = "Region where resources should be deployed"
  type        = string
}

// --- Clickhouse Instance Configuration --- //
variable "vm_firewall_tags" {
  description = "Additional tags to attach to deployed Clickhouse nodes, by default, no additional tags will be attached"
  type        = list(string)
  default     = []
}

variable "vm_clickhouse_vcpus" {
  description = "CPU count for Clickhouse instances, default '4'"
  type        = number
  default     = "4"
}

variable "vm_clickhouse_mem" {
  description = "Amount of memory allocated for Clickhouse instances (MiB), default '26624'"
  type        = number
  default     = "26624"
}

variable "vm_clickhouse_image" {
  description = "VM image to use for Clickhouse nodes"
  type        = string
}

variable "vm_clickhouse_image_project" {
  description = "Project hosting Clickhouse VM image"
  type        = string
}

variable "vm_clickhouse_boot_disk_size" {
  description = "Clickhouse VM boot disk size, default '250GB'"
  type        = string
  default     = "250GB"
}

variable "config_vm_clickhouse_data_volume_image" {
  description = "Clickhouse Data image name"
  type        = string
}

variable "config_vm_clickhouse_data_volume_image_project" {
  description = "Clickhouse Data image project, default 'open-targets-eu-dev'"
  type        = string
  default     = "open-targets-eu-dev"
}

variable "vm_flag_preemptible" {
  description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
  type        = bool
  default     = false
}

variable "deployment_target_size" {
  description = "This number configures how many instances should be running, default '1'"
  type        = number
  default     = 1
}
