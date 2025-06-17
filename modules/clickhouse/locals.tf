locals {
  // Ports
  clickhouse_http_req_port      = 8123
  clickhouse_node_exporter_port = 9100
  clickhouse_cli_req_port       = 9000
  clickhouse_metrics_port       = 9363
  clickhouse_http_req_port_name = "portclickhousehttp"
  clickhouse_metrics_port_name  = "portclickhousemetrics"
  clickhouse_node_exporter_name = "portclickhousenodeexp"
  clickhouse_cli_req_port_name  = "portclickhousereq"
  // Firewall tags
  fw_tag_clickhouse_node = "clickhousenode"

  // Clickhouse instance template values
  clickhouse_template_tags         = concat(var.vm_firewall_tags, [local.fw_tag_clickhouse_node])
  clickhouse_template_machine_type = "custom-${var.vm_clickhouse_vcpus}-${var.vm_clickhouse_mem}"
  clickhouse_template_source_image = "${var.vm_clickhouse_image_project}/${var.vm_clickhouse_image}"
  clickhouse_data_disk_snapshot    = "projects/${var.vm_clickhouse_data_volume_snapshot_project}/global/snapshots/${var.vm_clickhouse_data_volume_snapshot}"
  clickhouse_docker_image          = "${var.vm_clickhouse_docker_image}:${var.vm_clickhouse_docker_image_version}"
  // Clickhouse data disk device name
  clickhouse_data_disk_device = "ch-data"
  // Google Device Disk prefix
  gcp_device_disk_prefix = "/dev/disk/by-id/google-"

  ch_data_volume = "/mnt/disks/chdata"

  // Compute Zones internal parameters
  compute_zones_n_total = length(data.google_compute_zones.available.names)

  node_exporter_image = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
}
