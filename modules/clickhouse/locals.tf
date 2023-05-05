locals {
  // Ports
  clickhouse_http_req_port      = 8123
  clickhouse_cli_req_port       = 9000
  clickhouse_http_req_port_name = "portclickhousehttp"
  clickhouse_cli_req_port_name  = "portclickhousereq"
  // Firewall tags
  fw_tag_clickhouse_node = "clickhousenode"

  // Clickhouse instance template values
  clickhouse_template_tags         = concat(var.vm_firewall_tags, [local.fw_tag_clickhouse_node])
  clickhouse_template_machine_type = "custom-${var.vm_clickhouse_vcpus}-${var.vm_clickhouse_mem}"
  clickhouse_template_source_image = "${var.vm_clickhouse_image_project}/${var.vm_clickhouse_image}"
  clickhouse_data_disk_image       = "${var.vm_clickhouse_data_volume_image_project}/${var.vm_clickhouse_data_volume_image}"
  clickhouse_docker_image          = "${var.vm_clickhouse_docker_image}:${var.vm_clickhouse_docker_image_version}"
  // Clickhouse data disk device name
  clickhouse_data_disk_device = "ch-data"
  // Google Device Disk prefix
  gcp_device_disk_prefix = "/dev/disk/by-id/google-"

  // Compute Zones internal parameters
  compute_zones_n_total = length(data.google_compute_zones.available.names)
}
