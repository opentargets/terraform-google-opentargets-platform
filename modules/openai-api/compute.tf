// --- OpenAI API Compute resources --- //
resource "random_string" "openai_api_node" {
    length = 8
    special = false
    upper = false
    lower = true
    keepers = {
        template_tags = join("", sort(local.fw_vm_tags)),
        machine_type = local.vm_machine_type,
        source_image = local.vm_template_source_image,
        docker_fqdn_image = local.openai_api_docker_image,
        startup_script = md5(file("${path.module}/scripts/vm_startup.sh"))
    }
}