// --- Module Input Parameters --- //
// General deployment input parameters --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for resources names deployed by this module, default 'otpdevapi'"
  default = "otpdevapi"
}

variable "project_id" {
  description = "Project ID where to deploy resources"
}

