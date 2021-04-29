// Open Targets Platform Web Application deployment
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a deployment of Open Targets Platform Web Application
*/

// DEPRECATED --- //
/*resource "null_resource" "webapp_src_provisioner" {
  depends_on = [ module.bucket_webapp ]
  triggers = {
      bucket_name = module.bucket_webapp.website_bucket_name
  }
  provisioner "local-exec" {
      //command = "gsutil cp -r ${local.webapp_src_path_folder_build_web_app}/* ${module.bucket_webapp.bucket.url}"
      command = "/bin/bash ${path.module}/scripts/bucket_webapp_src_provisioner.sh"
      environment = merge({
            working_dir = local.webapp_provisioner_path_working_dir
            url_repo_webapp = local.webapp_src_provisioner_url_repo_webapp
            folder_root_webapp = local.webapp_src_provisioner_path_folder_root_webapp
            file_devops_context_template = local.webapp_src_provisioner_path_file_devops_context_template
            file_devops_context_instance = local.webapp_src_provisioner_path_file_devops_context_instance
            file_indexhtml = local.webapp_src_provisioner_path_file_indexhtml
            deployment_context_placeholder = var.webapp_deployment_context_placeholder
            docker_node_version = local.webapp_src_provisioner_docker_node_version
            build_script = local.webapp_src_provisioner_path_build_script
            folder_webapp_build = local.path_folder_build_web_app
            //bucket_webapp_url = module.bucket_webapp.bucket.url
            bucket_webapp_url = "gs://${module.bucket_webapp.website_bucket_name}"
        },
        local.webapp_provisioner_deployment_context
      )
  }
}
*/
