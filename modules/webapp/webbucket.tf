// This file defines the Google Storage Bucket set up for a static Web Application
resource "random_string" "random" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    webapp_release = var.webapp_release
    webapp_repository = var.webapp_repo_name
    robots_profile_name = var.webapp_robots_profile
    data_context_url = local.webapp_bundle_provisioner_url_bucket_data_context
    data_context_dst_folder = local.webapp_bundle_provisioner_data_context_dst_folder
    sitemaps_url_script_download = local.webapp_bundle_provisioner_sitemaps_url_script_download
    sitemaps_path_dst_sitemap_folder = local.webapp_bundle_provisioner_sitemaps_path_dst_sitemap_folder
    sitemaps_bigquery_project = local.webapp_bundle_provisioner_sitemaps_bigquery_project
    sitemaps_bigquery_table = local.webapp_bundle_provisioner_sitemaps_bigquery_table
    deployment_bundle_filename = local.webapp_deployment_bundle_filename
    deployment_scope = var.module_wide_prefix_scope
    deployment_context = md5(jsonencode(var.webapp_deployment_context))
    bundle_provisioning_script = md5(file(local.webapp_bundle_provisioner_path_script))
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
  // CORS
  enable_cors = true
  cors_origins = [ "*"]
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
        robots_active_file_name = local.webapp_bundle_provisioner_robots_active_file_name
        robots_profile_src_file_name = local.webapp_bundle_provisioner_robots_profile_src
        robots_profile_name = var.webapp_robots_profile
        customisation_profile_path_dst = local.webapp_bundle_provisioner_custom_profile_path_dst_path
        customisation_profile_path_src = local.webapp_bundle_provisioner_custom_profile_path_src_path
        data_context_url = local.webapp_bundle_provisioner_url_bucket_data_context
        data_context_dst_folder = local.webapp_bundle_provisioner_data_context_dst_folder
        deployment_bundle_filename = local.webapp_deployment_bundle_filename
        sitemaps_url_script_download = local.webapp_bundle_provisioner_sitemaps_url_script_download
        sitemaps_path_dst_sitemap_folder = local.webapp_bundle_provisioner_sitemaps_path_dst_sitemap_folder
        sitemaps_bigquery_project = local.webapp_bundle_provisioner_sitemaps_bigquery_project
        sitemaps_bigquery_table = local.webapp_bundle_provisioner_sitemaps_bigquery_table
      },
      local.webapp_provisioner_deployment_context
    )
    command = "/bin/bash ${local.webapp_bundle_provisioner_path_script}"
  }
}
