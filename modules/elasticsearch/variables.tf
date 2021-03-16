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

