locals {
  // Ports
  elastic_search_port_requests  = 9200
  elastic_search_port_comms     = 9300
  // Firewall tags
  fw_tag_elasticsearch_requests = "elasticsearchrequests"
  fw_tag_elasticsearch_comms = "elasticsearchcomms"

  // Elastic Search instance template values
  elastic_search_template_tags = concat(
    var.vm_firewall_tags,
    [
      local.fw_tag_elasticsearch_requests,
      local.fw_tag_elasticsearch_comms
    ]
  )
  elastic_search_template_machine_type = "custom-${var.vm_elastic_search_vcpus}-${var.vm_elastic_search_mem}"
  elastic_search_template_source_image = "${var.vm_elastic_search_image_project}/${var.vm_elastic_search_image}"
}