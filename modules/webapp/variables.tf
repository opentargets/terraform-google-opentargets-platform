// --- Web Application Module Input Parameters --- //
// General Deployment Information --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for naming resources in this deployment, default 'otpdevwebapp'"
  default = "otpdevwebapp"
}

variable "project_id" {
  description = "Project ID where resources will be deployed"
}

variable "location" {
  description = "This input value sets the bucket's location. Multi-Region or Regional buckets location values are supported, see https://cloud.google.com/storage/docs/locations#location-mr for more information. By default, the bucket is regional, location 'EUROPE-WEST4'"
  default = "EUROPE-WEST4"
}

