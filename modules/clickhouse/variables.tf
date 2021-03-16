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

