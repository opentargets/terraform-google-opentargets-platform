# Open Targets Platform API
This submodule defines the infrastructure needed to deploy Open Targets Platform Web Application.

Built as a Single Page Application (SPA), it is deployed in a Google Cloud Storage bucket, once the deployment configuration context has been injected in the web bundle.

# How to use the module
The module can be sourced from its GitHub URL as shown below.
```terraform
// --- Open Targets Platform API --- //
module "webapp" {
  source = "github.com/opentargets/terraform-google-opentargets-platform//modules/webapp"
  // ...
}
```

# Module configuration
The module implements the following input parameters.

## General configuration
>**module_wide_prefix_scope**, scoping prefix for naming resources in this deployment, default 'otpdevwebapp'.

>**project_id**, ID of the project that will host the deployed resources.

>**location**, this input value sets the bucket's location. Multi-Region or Regional buckets location values are supported, see [here](https://cloud.google.com/storage/docs/locations#location-mr) for more information. By default, the bucket is regional, location 'EUROPE-WEST4'

## Web Application configuration
>**webapp_repo_name**, Web Application repository name, where to find the bundle given a release version as well.

>**webapp_release**, release version of the web application to deploy (it will be used to locate the bundle within the given repository)

>**webapp_deployment_context_placeholder**, This defines the placeholder to replace within the public index.html, with the deployment context, default 'DEVOPS_CONTEXT_DEPLOYMENT' (**DEPRECATED**)

>**webapp_deployment_context**, values for parameterising the deployment of the web application, see defaults as an example.

>**webapp_docker_node_version**, Node version to use for building the bundle.

>**website_not_found_page**, it defines the website 'not found' page, default 'index.html'.

## Temporary assets
>**folder_tmp**, path to a temporary folder where to deploy working directories.
