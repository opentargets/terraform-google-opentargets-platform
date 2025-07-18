locals {
  // --- Bucket Configuration --- //
  multiregional_locations = [
    "ASIA",
    "EU",
    "US"
  ]
  bucket_storage_class = contains(local.multiregional_locations, var.location) ? "MULTI_REGIONAL" : "REGIONAL"
  bucket_name          = replace("${var.module_wide_prefix_scope}-${var.webapp_release}-${random_string.random.result}", ".", "-")
  //website_domain_name = var.website_domain_name == "" ? local.bucket_name_prefix : var.website_domain_name
  // --- Web App Provisioning --- //
  // Repo name
  webapp_provisioner_repo_name = var.webapp_repo_name
  // Working Dir base path
  webapp_provisioner_path_working_dir = abspath("${var.folder_tmp}/webapp_${var.webapp_release}")
  // Deployment Context
  webapp_provisioner_deployment_context = zipmap(
    keys(var.webapp_deployment_context),
    [for key, value in var.webapp_deployment_context :
      replace(
        value,
        "/",
        "\\/"
      )
    ]
  )
  // Source Code based provisioner --- //
  // TODO - Add the release information needed to check out only that version of the web app source code
  webapp_src_provisioner_url_repo_webapp                   = "git@github.com:${local.webapp_provisioner_repo_name}.git"
  webapp_src_provisioner_path_folder_root_webapp           = "${local.webapp_provisioner_path_working_dir}/websrc"
  webapp_src_provisioner_path_file_devops_context_template = "${local.webapp_src_provisioner_path_folder_root_webapp}/devopsContext.template"
  webapp_src_provisioner_path_file_devops_context_instance = "${local.webapp_src_provisioner_path_folder_root_webapp}/deploymentContext.js"
  webapp_src_provisioner_path_file_indexhtml               = "${local.webapp_src_provisioner_path_folder_root_webapp}/public/index.html"
  webapp_src_provisioner_docker_node_version               = var.webapp_docker_node_version
  webapp_src_provisioner_path_build_script                 = abspath("${path.module}/scripts/webapp_build_bundle.sh")
  webapp_src_path_folder_build_web_app                     = "${local.webapp_src_provisioner_path_folder_root_webapp}/build"
  // Bundle Based provisioner --- //
  webapp_bundle_provisioner_path_script                       = abspath("${path.module}/scripts/bucket_webapp_bundle_provisioner.sh")
  webapp_bundle_provisioner_url_bundle_download               = "https://github.com/${local.webapp_provisioner_repo_name}/releases/download/${var.webapp_release}/bundle.tar.gz"
  webapp_bundle_provisioner_path_build                        = "${local.webapp_provisioner_path_working_dir}/build"
  webapp_bundle_provisioner_file_name_devops_context_template = "config.template"
  webapp_bundle_provisioner_file_name_devops_context_instance = "config.js"
  webapp_bundle_provisioner_robots_active_file_name           = "robots.txt"
  webapp_bundle_provisioner_robots_profile_default            = "default"
  webapp_bundle_provisioner_robots_profile_src                = var.webapp_robots_profile != local.webapp_bundle_provisioner_robots_profile_default ? "${local.webapp_bundle_provisioner_robots_active_file_name}.${var.webapp_robots_profile}" : local.webapp_bundle_provisioner_robots_active_file_name
  webapp_bundle_provisioner_custom_profile_folder             = "${local.webapp_bundle_provisioner_path_build}/profiles"
  webapp_bundle_provisioner_custom_profile_path_dst_path      = "${local.webapp_bundle_provisioner_custom_profile_folder}/default.js"
  webapp_bundle_provisioner_custom_profile_path_src_path      = "${local.webapp_bundle_provisioner_custom_profile_folder}/${var.webapp_custom_profile}"
  webapp_bundle_provisioner_url_bucket_data_context           = "gs://${var.webapp_bucket_data_context_name}/${var.webapp_bucket_data_context_release}/${var.webapp_bucket_data_context_subfolder_name}"
  webapp_bundle_provisioner_data_context_dst_folder           = "data"
  webapp_bundle_provisioner_sitemaps_url_script_download      = "https://github.com/${var.webapp_sitemaps_repo_name}/releases/download/${var.webapp_sitemaps_release}/ot-sitemap.jar"
  webapp_bundle_provisioner_sitemaps_path_dst_sitemap_folder  = "${local.webapp_bundle_provisioner_path_build}/sitemaps"
  webapp_bundle_provisioner_sitemaps_bigquery_project         = var.webapp_sitemaps_bigquery_project
  webapp_bundle_provisioner_sitemaps_bigquery_table           = var.webapp_sitemaps_bigquery_table

  // --- Web Servers --- //
  // Communication Ports
  webapp_webserver_port      = 8080
  webapp_webserver_port_name = "webappserverport"
  // Firewall
  fw_tag_webserver_node = "webappservernode"
  // Web Server VM instance template values
  webapp_webserver_template_tags = concat(
    var.webserver_firewall_tags,
    [local.fw_tag_webserver_node]
  )
  webapp_webserver_disk_web_dev_name = "webdisk"
  // Machine geometry
  webapp_webserver_template_machine_type = "custom-${var.webserver_vm_vcpus}-${var.webserver_vm_mem}"
  webapp_webserver_template_source_image = "${var.webserver_vm_image_project}/${var.webserver_vm_image}"
  // Web Application Deployment Bundle
  webapp_deployment_bundle_filename = "deployment_bundle.tgz"
  webapp_deployment_bundle_url      = "https://storage.googleapis.com/${local.bucket_name}/${local.webapp_deployment_bundle_filename}"

  // --- Web App Deployment Context --- //
  webapp_env_vars = join(" ",
    [for key, value in var.webapp_deployment_context_env :
      "-e \"${key}=${value}\""
    ]
  )
}
