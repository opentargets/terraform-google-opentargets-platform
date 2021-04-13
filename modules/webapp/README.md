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
>**webapp_repo_name**, 

>**webapp_release**, 

>**webapp_deployment_context_placeholder**, 

>**webapp_deployment_context**, 

>**webapp_docker_node_version**, 

>**website_not_found_page**, 

## Temporary assets
>**folder_tmp**, 
