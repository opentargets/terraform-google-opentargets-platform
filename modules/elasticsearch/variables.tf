// --- Module input parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "The prefix provided here will scope names for those resources created by this module, default 'otpdeves'"
  default = "otpdeves"
}

variable "network_name" {
  description = "Name of the network where resources should be deployed, 'default'"
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

variable "network_source_ranges" {
  description = "CIDR that represents which IPs we want to grant access to the deployed resources, default '10.0.0.0/9'"
  default = [ "10.0.0.0/9" ]
}

variable "deployment_region" {
  description = "Region where resources should be deployed"
}

// --- Elastic Search Instance configuration --- //
variable "deployment_target_size" {
  description = "Initial Elastic Search node count to deploy, default is '1'"
  default = 1
}

variable "vm_firewall_tags" {
  description = "Additional tags that should be attached to any Elastic Search Node deployed by this module"
  default = [ ]
}

variable "vm_elastic_search_version" {
  description = "Elastic Search Docker Image version to use"
}

