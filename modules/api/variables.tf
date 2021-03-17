// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for resources names deployed by this module, default 'otpdevapi'"
  default = "otpdevapi"
}

variable "project_id" {
  description = "Project ID where to deploy resources"
}

variable "network_name" {
  description = "Name of the network where resources should be connected to, default 'default'"
  default = "default"
}

variable "network_self_link" {
  description = "Self link to the network where resources should be connected when deployed"
  default = "default"
}

variable "network_subnet_name" {
  description = "Name of the subnet, within the 'network_name', and the given region, where instances should be connected to"
  default = "main-subnet"
}

variable "network_source_ranges_map" {
  description = "CIDR that represents which IPs we want to grant access to the deployed resources"
/*[
    region = {
      subnet_ip = "CIDR"
    }
  ]
 */
}

// --- API Instances configuration --- //
variable "deployment_regions" {
  description = "List of regions where the API nodes should be deployed"
}

variable "vm_firewall_tags" {
  description = "List of additional tags to attach to API nodes"
  default = [ ]
}

variable "vm_platform_api_image_version" {
  description = "API Docker image version to use in deployment"
}

variable "vm_api_vcpus" {
  description = "CPU count for API nodes, default '2'"
  default = "2"
}

variable "vm_api_mem" {
  description = "Amount of memory allocated for API nodes (MiB), default '7680'"
  default = "7680"
}

variable "vm_api_image" {
  description = "VM image to use for API nodes, default 'cos-stable'"
  default = "cos-stable"
}

variable "vm_api_image_project" {
  description = "Project hosting the VM image, default 'cos-cloud'"
  default = "cos-cloud"
}

variable "vm_api_boot_disk_size" {
  description = "Boot disk size for API nodes, default '10GB'"
  default = "10GB"
}

