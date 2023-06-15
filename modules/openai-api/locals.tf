locals {
  // Communication Ports
  openai_api_port      = 8080
  openai_api_port_name = "openaiapiport"
  // Firewall
  fw_tag_openai_api = "openaiapinode"
  // Compute
  fw_vm_tags = concat(
    var.vm_tags,
    [local.fw_tag_openai_api]
  )
  // Compute Instances (VMs)
  vm_template_source_image = "${var.vm_image_project}/${var.vm_image}"
  vm_machine_type          = var.vm_machine_type
  // Docker
  // Effective Docker Image
  openai_api_docker_image = "${var.openai_api_docker_image}:${var.openai_api_docker_image_version}"
  // Docker Container name
  openai_api_container_name = "ot-openai-api"
}