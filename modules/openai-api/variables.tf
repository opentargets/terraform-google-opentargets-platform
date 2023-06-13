// --- OpenAI API Module Input Parameters --- //
// General Deployment Information --- //
variable "module_wide_prefix_scope" {
  description = "Scoping prefix for naming resources in this deployment, default 'otpdevopenaiapi'"
  type        = string
  default     = "otpdevopenaiapi"
}

variable "project_id" {
  description = "Project ID where resources will be deployed"
  type        = string
}

// --- OpenAI API Configuration --- //
variable "openai_api_docker_image" {
    description = "OpenAI API Docker image to deploy"
    type        = string
    default = "quay.io/opentargets/"
}

variable "openai_api_docker_image_version" {
    description = "OpenAI API Docker image version to deploy"
    type        = string
    default = "latest"
}

// --- Machine geometry --- //
variable "vm_type" {
    description = "Machine type to use for the OpenAI API deployment, default 'n1-standard-1'"
    type        = string
    default     = "n1-standard-1"
}

variable "vm_disk_size" {
    description = "Machine disk size to use for the OpenAI API deployment, default '10'"
    type        = number
    default     = 10
}

// --- Machine image --- //
variable "vm_image" {
    description = "Machine image to use for the OpenAI API deployment, default 'cos-stable'"
    type        = string
    default     = "cos-stable"
}

variable "vm_image_project" {
    description = "Machine image project to use for the OpenAI API deployment, default 'cos-cloud'"
    type        = string
    default     = "cos-cloud"
}

// --- Machine Persona --- //
variable "vm_flag_preemptible" {
    description = "Use this flag to tell the module to use a preemptible instance, default: 'false'"
    type        = bool
    default     = false
}

// --- Machine tags --- //
variable "vm_tags" {
    description = "List of additional tags to attach to OpenAI API nodes"
    type        = list(string)
    default     = []
}