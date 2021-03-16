// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "The prefix provided here will scope names for those resources created by this module, default 'otpdevch'"
  default = "otpdevch"
}

variable "network_name" {
  description = "Name of the network resources will be connected to, default 'default'"
  default = "default"
}

variable "network_self_link" {
  description = "Self link to the network where resources should be connected when deployed, default 'default'"
  default = "default"
}

variable "network_subnet_name" {
  description = "Name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'"
  default = "main-subnet"
}

variable "network_source_ranges" {
  description = "CIDR that represents which IPs we want to grant access to the deployed resources, default '10.0.0.0/9'"
  default = [ "10.0.0.0/9" ]
}

variable "deployment_region" {
  description = "Region where resources should be deployed"
}

// --- Clickhouse Instance Configuration --- //
variable "vm_firewall_tags" {
  description = "Additional tags to attach to deployed Clickhouse nodes, by default, no additional tags will be attached"
  default = [ ]
}

variable "vm_clickhouse_vcpus" {
  description = "CPU count for Clickhouse instances, default '4'"
  default = "4"
}

