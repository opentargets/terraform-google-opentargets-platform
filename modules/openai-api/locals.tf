locals {
  // Communication Ports
  openai_api_port                = 8080
  openai_node_exporter_port      = 9100
  openai_api_port_name           = "openaiapiport"
  openai_node_exporter_port_name = "openainodeexpport"
  // Firewall
  fw_tag_openai_api = "openaiapinode"
  // Compute
  fw_vm_tags = concat(
    var.vm_tags,
    [local.fw_tag_openai_api]
  )
  // Compute Instances (VMs)
  vm_machine_type = var.vm_type
  // Docker
  // Effective Docker Image
  openai_api_docker_image = "${var.openai_api_docker_image}:${var.openai_api_docker_image_version}"
  // Docker Container name
  openai_api_container_name = "ot-openai-api"

  node_exporter_image = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
  alloy_container        = "${var.alloy_image_name}:${var.alloy_image_version}"
  alloy_endpoint         = "http://${var.observabilty_servers[0]}:3100/loki/api/v1/push"
}