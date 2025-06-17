locals {
  // API Communication Ports
  otp_api_port                    = 8080
  otp_api_node_exporter_port      = 9100
  otp_api_node_exporter_port_name = "otpapinodeexpport"
  otp_api_port_name               = "otpapiport"
  // Firewall
  fw_tag_otp_api_node = "otpapinode"
  // GLB tagging for traffic destination
  glb_tag_target_node = "otpapi-glb-target"
  // Load Balancer types
  lb_type_internal = "INTERNAL"
  lb_type_global   = "GLOBAL"
  lb_type_none     = "NONE"
  input_validation_load_balancer_type_allowed_values = [
    local.lb_type_internal,
    local.lb_type_global,
    local.lb_type_none
  ]
  // API VM instance template values
  otpapi_template_tags = concat(
    var.vm_firewall_tags,
    [
      local.fw_tag_otp_api_node, local.glb_tag_target_node
    ]
  )
  otpapi_template_machine_type = "custom-${var.vm_api_vcpus}-${var.vm_api_mem}"
  otpapi_template_source_image = "${var.vm_api_image_project}/${var.vm_api_image}"
  node_exporter_image          = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
}