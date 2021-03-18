// Open Targets Platform Web Application deployment
// Author: Manuel Bernal Llinares <mbdebian@gmail.com>

/*
    This module defines a deployment of Open Targets Platform Web Application
*/
resource "random_string" "random" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    webapp_release = var.webapp_release
    deployment_scope = var.module_wide_prefix_scope
  }
}

// --- Website Bucket Definition --- //
module "bucket_webapp" {
  source  = "github.com/mbdebian/terraform-google-static-assets//modules/cloud-storage-static-website"
  project = var.project_id
  // Website and Logs buckets configuration
  website_domain_name = local.bucket_name
  access_log_prefix = "${var.module_wide_prefix_scope}-${var.webapp_release}"
  force_destroy_website = true
  force_destroy_access_logs_bucket = true
  website_location = var.location
  website_storage_class = local.bucket_storage_class
  // Pages configuration
  not_found_page = var.website_not_found_page
  // Access logs configuration
  access_logs_expiration_time_in_days = 30
}

// --- Web Application Content Provisioner ---
resource "null_resource" "webapp_provisioner" {
  depends_on = [ module.bucket_webapp ]
  triggers = {
    bucket_name = module.bucket_webapp.website_bucket_name
  }
  provisioner "local-exec" {
    working_dir = var.folder_tmp
    environment = merge({
        working_dir = local.webapp_provisioner_path_working_dir
        url_bundle_download = local.webapp_bundle_provisioner_url_bundle_download
        path_build = local.webapp_bundle_provisioner_path_build
        file_name_devops_context_template = local.webapp_bundle_provisioner_file_name_devops_context_template
        file_name_devops_context_instance = local.webapp_bundle_provisioner_file_name_devops_context_instance
        bucket_webapp_url = "gs://${module.bucket_webapp.website_bucket_name}"
      },
      local.webapp_provisioner_deployment_context
    )
    command = "/bin/bash ${local.webapp_bundle_provisioner_path_script}"
  }
}

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
