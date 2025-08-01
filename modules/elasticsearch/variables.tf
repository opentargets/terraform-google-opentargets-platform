// --- Module input parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "The prefix provided here will scope names for those resources created by this module, default 'otpdeves'"
  type        = string
  default     = "otpdeves"
}

variable "project_id" {
  description = "Project ID where to deploy resources"
  type        = string
}

variable "network_name" {
  description = "Name of the network where resources should be deployed, 'default'"
  type        = string
  default     = "default"
}

variable "network_self_link" {
  description = "Self link to the network where resources should be connected when deployed"
  type        = string
  default     = "default"
}

variable "network_subnet_name" {
  description = "Name of the subnet, within the 'network_name', and the given region, where instances should be connected to"
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

// --- Elastic Search Instance configuration --- //
variable "deployment_target_size" {
  description = "Initial Elastic Search node count to deploy, default is '1'"
  type        = number
  default     = 1
}

variable "vm_firewall_tags" {
  description = "Additional tags that should be attached to any Elastic Search Node deployed by this module"
  type        = list(string)
  default     = []
}

variable "vm_elastic_search_version" {
  description = "Elastic Search Docker Image version to use"
  type        = string
}

variable "vm_elastic_search_vcpus" {
  description = "CPU count for each Elastic Search Node VM"
  type        = number
}

variable "vm_elastic_search_mem" {
  description = "Amount of memory assigned to every Elastic Search Instance (MiB)"
  type        = number
}

variable "vm_elastic_search_image" {
  description = "VM Image to use for Elastic Search instances"
  type        = string
  default     = "cos-stable"
}

variable "vm_elastic_search_image_project" {
  description = "Project hosting the Elastic Search VM Instance image"
  type        = string
  default     = "cos-cloud"
}

variable "vm_elastic_search_boot_disk_size" {
  description = "Elastic Search instances boot disk size, default '500GB'"
  type        = string
  default     = "16"
}

variable "vm_elastic_search_data_volume_snapshot" {
  description = "Elastic Search Data volume snapshot name"
  type        = string
}

variable "vm_elastic_search_data_volume_snapshot_project" {
  description = "Elastic Search Data image project, default 'open-targets-eu-dev'"
  type        = string
  default     = "open-targets-eu-dev"
}


variable "vm_flag_preemptible" {
  description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
  type        = bool
  default     = false
}

variable "node_exporter_image_name" {
  description = "Image used to create the node exporter container."
  default     = "quay.io/prometheus/node-exporter"
}

variable "node_exporter_image_version" {
  description = "Image version of the node exporter image."
  default     = "v1.9.1"
}
