# Infrastructure definition
This repository defines the Open Targets Platform infrastructure, using Hashicorp Configuration Language (HCL) and [Terraform](https://terraform.io).

![Open Targets Platform, Deployment Unit](docs/img/open_targets_platform_infrastructure.png "Open Targets Platform, Deployment Unit")

As shown in the figure above, a deployment unit consists of two data backends, based on Elastic Search and Clickhouse services. Set to automatically scale up on demand and self-heal, as part of the managing activities in their scoping regional instance group.

These services are accessible by the backend API via their respective Internal Load Balancers, which not only distributes the requests among available instances, but also prevents a broken instance from receiving any traffic.

Open Targets platform API services are deployed as a collection of instances in a regional group, set behind a Global Load Balancer, that serves requests from the internet to these services via HTTP and HTTPS, being SSL terminated at this infrastructure entry point.

The platform web frontend is deployed in a Google Cloud Storage Bucket, not shown in the picture above, that is also behind this Global Load Balancer.

We use Google Cloud DNS services for all domain names deployed via this infrastructure definition.

# FAIR Principles
Open Targets Platform Infrastructure has been defined using [Terraform Modules](https://www.terraform.io/docs/language/modules/develop/index.html).

The platform has been broken down into the following components:
- [Clickhouse](modules/clickhouse)
- [Elastic Search](modules/elasticsearch)
- [API](modules/api)
- [Web frontend](modules/webapp)

Each component is defined and encapsulated as a submodule that can be reused independently, in any Google Cloud environment run, or not, by Open Targets.

These modules are accessible by the community via our Open Source license, as well as their underlying machine images (via their corresponding licenses).

This repository itself makes use of them as a Terraform Root Module, to build what constitutes Open Targets Platform. In addition, this root module is also available to the community via our Open Source license, thus, anyone can use it for deploying the platform in any Google Cloud project environment.

This also simplifies our development, testing, QA and staging workflows internally at Open Targets, by doing a lot of heavy lifting for our backend and frontend engineers.

# Open Targets Platform Deployment Process
Prior to working with this infrastructure definition, you need to make sure that you have:
- _Terraform_ v1.3.9 or later
- _Google Cloud SDK_ 420.0.0 or later, with valid credentials
- _Makefile_ enabled environment, with common command line tools, e.g. wget

Clone the repository, if you have GitHub Cli:
```
gh repo clone opentargets/terraform-google-opentargets-platform
```

## Activating GCP credentials

To interact with GCP services it is necessary to be authenticated. Follow the directions in the [google module documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#primary-authentication).

If you are already signed in to the `gcloud` utility (check with `gcloud auth list`) executing the following command should be sufficient:

```
gcloud auth application-default login
```

## Terraform State
Terraform uses a [state file](https://www.terraform.io/docs/language/state/index.html) that allows it to track the managed infrastructure.

The information is stored in a file, and this file can reside in the local file system, or somewhere else, e.g. a Google Cloud Bucket.

This is known as _Terraform backend_, and, by default, it is set to use a location in one of our buckets.

When you clone this repository, and want to use this code outside Open Targets, you need to update the file ```backend.tf``` with the details of where you'd like to save your Terraform state.

## Deployment Contexts
To put together all the elements that make up an Open Targets Platform deployment for its different versions, either production releases or development branches, we use the idea of _Deployment Contexts_, defined in the _profiles_ folder, and used to define the different versions of the platform that we want to deploy.

In a nutshell, a _Deployment Context_ is a set of variables that define the version of the platform to be deployed, and the infrastructure that will be used to host it, i.e. all the configuration parameters that can be customized for deploying the platform.

To simplify the process of working with these _Deployment Contexts_, we have split its contents into different layers.

### Layer 1, underlying cloud provider
The first layer is the one that defines the underlying cloud provider, in this case, Google Cloud, and it is implemented in the file ```01-defaults-gcp.auto.tfvars```.

This file contains the default values for all the variables that are specific to Google Cloud, and are used by the modules that make up the platform.

### Layer 2, Machines Geometry
The second layer defines the geometry of the machines that will be used to host the platform, and it is implemented through a series of files (each related to a specific platform service or component):
- ```10-vm_geometry-api.auto.tfvars```, for the API.
- ```10-vm_geometry-clickhouse.auto.tfvars```, for the Clickhouse data backend.
- ```10-vm_geometry-elastic_search.auto.tfvars```, for the Elastic Search data backend.
- ```10-vm_geometry-web_server.auto.tfvars```, for the machines that host the web frontend.

As an example of machine geometry settings, the following snippet shows the values for the API machines:
```hcl
// API Node --- //
config_vm_api_vcpus          = "2"
config_vm_api_mem            = "7680"
config_vm_api_boot_disk_size = "10GB"
```

### Layer 3, Machines Persona
The third layer defines the machine's persona that will be used in the deployment, and it is implemented through a series of files (each related to a specific platform service or component):
- ```11-vm_persona-api.auto.tfvars```, for the API.
- ```11-vm_persona-clickhouse.auto.tfvars```, for the Clickhouse data backend.
- ```11-vm_persona-elastic_search.auto.tfvars```, for the Elastic Search data backend.
- ```11-vm_persona-web_server.auto.tfvars```, for the machines that host the web frontend.

As an example of machine persona settings, the following snippet shows the values for the API machines:
```hcl
// API Node --- //
// By default, we use the development configuration, where the provisioning model for VMs is preemptible.
config_vm_api_flag_preemptible = true
```

Across the different layers, the configuration parameters corresponding to a development environment are the ones used by default.

### Layer 4, Operating System
The fourth layer defines the operating system that will be used in the deployed machines, and it is implemented through a series of files (each related to a specific platform service or component):
- ```20-vm_os-api.auto.tfvars```, for the API.
- ```20-vm_os-clickhouse.auto.tfvars```, for the Clickhouse data backend.
- ```20-vm_os-elastic_search.auto.tfvars```, for the Elastic Search data backend.
- ```20-vm_os-web_server.auto.tfvars```, for the machines that host the web frontend.

As an example of operating system settings, the following snippet shows the values for the API machines:
```hcl
// API node --- //
config_vm_api_image         = "cos-stable"
config_vm_api_image_project = "cos-cloud"
```

### Layer 5, Software
The fifth layer defines the software that we'll run on the deployed machines, on top of the OS, and it is implemented through a series of files (each related to a specific platform service or component):
- ```30-vm_sw-api.auto.tfvars```, for the API.
- ```30-vm_sw-clickhouse.auto.tfvars```, for the Clickhouse data backend.
- ```30-vm_sw-elastic_search.auto.tfvars```, for the Elastic Search data backend.
- ```30-vm_sw-web_server.auto.tfvars```, for the machines that host the web frontend.

As an example of software settings, the following snippet shows the values for the Elastic Search machines:
```hcl
// Elastic Search node --- //
// This is the Elastic Search Docker image we will use for the Elastic Search node.
config_vm_elastic_search_version = "7.10.2"
```

### Layer 6, Security
The sixth layer defines the security policies and related configuration for the deployment of the infrastructure.

It is implemented in the file ```50-security.auto.tfvars```.

In the current infrastructure iteration, two areas are covered:
- The access to API
- The access to the web frontend

### Layer 7, DNS Configuration
The seventh layer defines the DNS configuration for the deployment, in file ```60-dns.auto.tfvars```.

The following snippet shows the default DNS configuration, which is used for the development environment:
```hcl
// By default, we use the development DNS configuration
config_dns_project_id             = "open-targets-eu-dev"
config_dns_subdomain_prefix       = "dev"
config_dns_managed_zone_name      = "opentargets-xyz"
config_dns_managed_zone_dns_name  = "opentargets.xyz."
config_dns_platform_api_subdomain = "api"
```

This settings are related to the Cloud DNS service configured in _open-targets-eu-dev_ project, and the _opentargets-xyz_ managed zone, building the following DNS URL: ```api.dev.opentargets.xyz```.

### Layer 8, Global Load Balancer
The eighth layer defines the configuration for the Global Load Balancer that will be used to expose the platform to the outside world, in file ```70-glb.auto.tfvars```.

The main aspect of the GLB that can be customized is related to whether we want to use a CDN or not, which is controlled by the following parameter:
```hcl
// By default, we use the development configuration
config_glb_webapp_enable_cdn = false
```

### Layer 9, Web Frontend sitemaps
The ninth layer defines the sitemaps for the web frontend, in file ```80-sitemaps.auto.tfvars```.

The following snippet shows the default sitemaps configuration, which is used for the development environment:
```hcl
// Sitemaps default configuration, it matches Development Environment
config_webapp_sitemaps_repo_name        = "opentargets/ot-sitemap-cli"
config_webapp_sitemaps_release          = "1.1.0"
config_webapp_sitemaps_bigquery_table   = "platform_dev"
config_webapp_sitemaps_bigquery_project = "open-targets-eu-dev"
```

This setting uses a tool at GitHub repository [opentargets/ot-sitemap-cli](https://github.com/opentargets/ot-sitemap-cli) to generate the sitemaps for the web frontend, based on the data of the BigQuery dataset _platform\_dev_ in _open-targets-eu-dev_ project.

### Layer 10, Web Frontend environment
The tenth layer defines the environment variables for the web frontend, in file ```81-web_env.auto.tfvars```.

The following snippet shows the default web frontend environment configuration, which is used for the development environment:
```hcl
// Default configuration for the web application is the Development Environment
config_webapp_deployment_context_map = {
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API      = "'https://api.platform.dev.opentargets.xyz/api/v4/graphql'"
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API_BETA = "'https://api.platform.dev.opentargets.xyz/api/v4/graphql'"
  DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_EFO_URL      = "'/data/ontology/efo_json/diseases_efo.jsonl'"
}
// Robots.txt profile --- //
config_webapp_robots_profile = "default"
// Web Application Customisation Profile --- //
// Using the default profile
// config_webapp_custom_profile = "default.js"
```

It defines environment configuration that will be shipped with the frontend to the web servers, as well as which _robots.txt_ profile and custommization profiles will be used.

### Layer 11, Monitoring Configuration
The eleventh layer defines the configuration for the monitoring of the platform, in file ```90-monitoring.auto.tfvars```.

This layer sets, among other things, development and monitoring facilities for the deployed infrastructure, such as:
- Enable/disable SSH access to the machines.
- Enable/disable additional VMs for inspection and monitoring purposes from within each deployment region.

The following snippet shows the default monitoring configuration, which is used for the development environment:
```hcl
// Development facilities //

// Development mode will enable the following features:
// - SSH access to deployed instances
config_set_dev_mode_on = true

// Inspection will enable the following features:
// - An SSH enabled instance within the same VPC as the deployed instances, for every deployed region
//config_enable_inspection                    = true
```

### Layer 12, Deployment Context
This is the final layer that defines the deployment context, which groups together those elements that change in-between releases (mainly).

It is implemented through a configuration management system based on the use of _profiles_, which are defined in the _profiles_ folder, and defined as _deployment\_context.<profile\_name>_.

For example, the _profiles/deployment\_context.2302_ profile defines the deployment context for Open Targets Platform 23.02 release, as it can be seen in the following snippet:
```hcl
// --- PRODUCTION Open Targets Platform ---//

// --- Release Specific Information (THIS IS THE MAIN PLACE WHERE THINGS CHANGE BETWEEN PRODUCTION RELEASES) --- //
// Regions
config_deployment_regions                   = [ "europe-west1" ]
// Elastic Search configuration
config_vm_elastic_search_image              = "mbdevplatform-230214-031922-es"
// Clickhouse configuration
config_vm_clickhouse_image                  = "mbdevplatform-230214-031922-ch"
// API configuration
config_vm_platform_api_image_version        = "dev23.02.7"
config_vm_version_major                     = "23"
config_vm_version_minor                     = "02"
config_vm_version_patch                     = "7"
config_vm_data_year                         = "23"
config_vm_data_month                        = "02"
config_vm_data_iteration                    = "0"
// Web App configuration
config_webapp_release                       = "v0.3.4"
// Web App Data Context
config_webapp_bucket_name_data_assets       = "open-targets-data-releases"
config_webapp_data_context_release          = "23.02"
// -[END]- Release Specific Information --- //



// --- This section is common to all production releases, unless custom changes need to be made --- //
// Deployment configuration
config_release_name                         = "production"
config_project_id                           = "open-targets-platform"
// DNS
config_dns_project_id                       = "open-targets-prod"
config_dns_subdomain_prefix                 = null
config_dns_managed_zone_name                = "opentargets-org"
config_dns_managed_zone_dns_name            = "opentargets.org."
config_dns_platform_api_subdomain           = "api"
// Web App configuration
config_webapp_deployment_context_map        = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API = "'https://api.platform.opentargets.org/api/v4/graphql'"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_API_BETA = "'https://api.platform.opentargets.org/api/v4/graphql'"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_EFO_URL = "'/data/ontology/efo_json/diseases_efo.jsonl'"
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_GOOGLE_TAG_MANAGER_ID = "'GTM-WPXWRDV'"
}
// Robots.txt profile
config_webapp_robots_profile                = "production"
// Sitemaps generation
config_webapp_sitemaps_bigquery_table       = "platform"
config_webapp_sitemaps_bigquery_project     = "open-targets-prod"
// Machines' Persona configuration
// For Production, we use 'on-demand' provisioning model
config_vm_api_flag_preemptible = false
config_vm_clickhouse_flag_preemptible = false
config_vm_elasticsearch_flag_preemptible = false
config_vm_webserver_flag_preemptible = false
```

The _Release Specific Information_ section is the one that changes in-between releases, and it is the one that should be modified when a new release is deployed. It contains information about the regions where the infrastructure will be deployed, the images that will be used for the data backend VMs, the version of the API and Web App that will be deployed, and the data context that will be used.

## Working with this Infrastructure Definition
To simplify operations related to working with this infrastructure definition, we have implemented a _Makefile_ helper with the following operations:
```shell
Usage:
  make 
  help             show help message
  status           Show the current status of the deployment context
  set_profile      Set the profile to be used for all the operations in the session (use parameter 'profile')
  update_linked_profile  Update a linked deployment context profile to point to a new one, e.g. 'production-platform' -> '23.02', (use parameters 'profile' and 'link_to_profile')
  clone_profile    Clone an existing profile to a new one, starting with an empty workspace (state), and activate the new deployment context profile, as well as its corresponding workspace, use parameters 'profile' and 'new_profile'
  delete_profile   Delete an existing profile, use parameter 'profile'
  unset_profile    Unset the currently active profile
  clean_backend    Clean Terraform Backend Cache
  clean            Clean up all the artifacts created by this helper (profile, backend, etc.)
```

## Example: Working with a particular deployment context
In this example, we are going to show the steps to work with the development deployment context, _dev-platform_.

The first step after clonning the repository, is to set the _active profile_
```shell
make set_profile profile=dev-platform
```
This command will set the _active profile_ to _dev-platform_, and it will also activate the corresponding _Terraform Environment_ (Workspace).

A new file, ```deployment_context.auto.tfvars``` will be created as a symbolic link to the corresponding profile file, ```profiles/deployment_context.dev-platform```.

Now we initialize the _Terrafom backend_ for the active profile
```shell
terraform init
```

To plan / apply changes to the infrastructure, based on the active profile, we use standard _Terraform_ commands:
```shell
terraform plan
# To apply changes
terraform apply
```

Once we are done with the changes, we can deactivate the _active profile_ by running the following command:
```shell
make unset_profile
```
This will prevent any accidental changes to the infrastructure.

## New Deployment Context profiles
To create a new deployment context profile, based on an existing one, we can use the ```clone_profile``` target, e.g. for a new profile named _test_ based on the _dev-platform_ profile, we can run the following command:
```shell
make clone_profile profile=dev-platform new_profile=test
```

This will create a new profile file, ```profiles/deployment_context.test```, activate the profile, and create a new _Terraform Environment_ (Workspace) for it (with the same name as the profile).

## Linked Deployment Context profiles
A _linked profile_ is a profile that points to another profile, and it is used to simplify the process of updating the infrastructure when new releases are deployed.

For example, the _production-platform_ profile is a _linked profile_ that points to the _2302_ profile, which is the profile that corresponds to the latest release of the Open Targets Platform (at the time of writing this document).

_production-platform_ linked profile is, actually, the one we use for our production deployment.

To update the _production-platform_ profile to point to a new profile, we can use the ```update_linked_profile``` target, e.g. to update the _production-platform_ profile to point to a new profile with name _2304_ (which corresponds to the coming release 23.04) we can run the following command:
```shell
make update_linked_profile profile=production-platform link_to_profile=2304
```

## Deleting Deployment Context profiles
Deleting an existing profile will:
- Delete the corresponding _Terraform Environment_ (Workspace) (with automatic destruction of all the resources tracked by Terraform in that environment)
- Delete the corresponding profile file

As an example, to delete _test_ profile, we can run the following command:
```shell
make delete_profile profile=test
```

## Housekeeping
Two targets are provided for housekeeping related tasks:
- ```clean_backend```: This target will clean the _Terraform backend_ cache, by removing all the files in the ```.terraform``` directory.
- ```clean```: This target will clean all the artifacts created by this helper, including the _active profile_ (deactivate / unset) and the _Terraform backend_ cache.

# Deployment Context Explained
This section explains the different sections of the deployment context file, and the parameters that can be used to configure the deployment, through the different definition layers.

## Layered configuration parameters

### Layer 1, Underlying cloud provider
>**config_gcp_default_region**, default deployment region when no region is specified, this parameters is related to the cloud provider configuration, in this case Google Cloud Platform.

>**config_gcp_default_zone**, default deployment zone when no zone is specified, this parameters is related to the cloud provider configuration, in this case Google Cloud Platform.

>**config_project_id**, Google Cloud Project ID that will be the destination for deployed resources.

### Layer 2, Machines Geometry
API nodes used as example
>**config_vm_api_vcpus**, CPU count to be allocated for every Open Targets Platform API instance.

>**config_vm_api_mem**, amount of memory to be allocated for every Open Targets Platform API instance (MiB).

>**config_vm_api_boot_disk_size**, VM boot disk size to attach to the Open Targets Platform API instances.

### Layer 3, Machines Persona
API nodes used as example
> config_vm_api_flag_preemptible, flag to indicate if the Open Targets Platform API instances should use SPOT or ON_DEMAND provisioning models.


### Layer 4, Operating System
>**config_vm_api_image**, VM image ID for Open Targets Platform API instances.

>**config_vm_api_image_project**, VM images may be hosted in a project different than the recipient of the resources being deployed, which ID is specified here.

### Layer 5, Software
Elastic Search nodes used as example
>**config_vm_elastic_search_version**, Docker image version for running Elastic Search within the VM isntances.

### Layer 6, Security
>**config_security_api_enable**, whether to restrict access to the deployed API based on the provided CIDR listing or not.

>**config_security_webapp_enable**, whether to restrict access to the deployed web application based on the provided CIDR listing or not.


### Layer 7, DNS Configuration
>**config_dns_project_id**, ID of the Google Cloud Project that hosts the Cloud DNS services where DNS entries will be registered.

>**config_dns_managed_zone_name**, name of the Cloud DNS managed zone where entries can be registered.

>**config_dns_subdomain_prefix**, if supplied, this parameters allows for the resources be "scoped" within a subdomain in the DNS, this way, multiple deployments can share the main root domain name.

>**config_dns_managed_zone_dns_name**, root domain name associated to the managed DNS zone.

>**config_dns_platform_api_subdomain**, which subdomain to use fot Open Targets Platform API services, default is 'platform'.

### Layer 8, Global Load Balancer
**config_glb_webapp_enable_cdn**, whether or not a CDN should be used for serving the web application.

### Layer 9, Web Frontend sitemaps
>**config_webapp_sitemaps_repo_name**, GitHub repo where to find the sitemaps generator, e.g. _opentargets/ot-sitemap-cli_

>**config_webapp_sitemaps_release**, GitHub release number to use for sitemaps generation.

>**config_webapp_sitemaps_bigquery_table**, BigQuery table where the data for generating sitemaps can be found.

>**config_webapp_sitemaps_bigquery_project**, project where BigQuery table for sitemaps is set.


### Layer 10, Web Frontend environment
>**config_webapp_deployment_context_map**, this is a simple key-value collection that will be injected as configuration in the web application when deployed.

>**config_webapp_robots_profile**, _robots.txt_ profile that should be set in the given deployment.

>**config_webapp_custom_profile**, web application customisation profile to be set in the given deployment.

### Layer 11, Monitoring Configuration
>**config_set_dev_mode_on**, when development mode is active, SSH traffic to all deployed VMs is enabled, and inspection VMs are deployed.

>**config_enable_inspection**, when true, an extra VM per region will be deployed, for internal access to deployed infrastructure.

### Layer 12, Deployment Context (top most layer)
Values present in this layer, overwrite values from the underlying layers.

This listing is not exhaustive, but it includes the most important parameters, not mentioned earlier, that can be used to configure the deployment.

>**config_release_name**, its value will be used for prefix-scoping names / IDs of deployed resources

>**config_deployment_regions**, a list of Google Cloud regions for deploying Open Targets Platform across.

>**config_vm_elastic_search_image**, VM image ID for Open Targets Elastic Search instances.

>**config_vm_clickhouse_image**, VM image ID for Open Targets Clickhouse instances.

>**config_vm_platform_api_image_version**, Open Targets Platform API image version to deploy.

>**config_webapp_release**, GitHub tag release.

>**config_webapp_repo_name**, GitHub repository where to fetch the bundle from.

>**config_webapp_bucket_name_data_assets**, bucket name where to find the data assets that will be used for the web application data context.

>**config_webapp_data_context_release**, subfolder within the data bucket where to find that web application data context.

>**config_webapp_webserver_docker_image_version**, Docker image version for running the web server that attends web application requests.


(TODO - Security configuration parameters)

## Output Information
Once the deployment process has been successfully completed, the following details about the resources are revealed.

>**network_region_subnet_mapping**, a custom VPC is created for every deployment context of Open Targets Platform, and, as a result, information on the created custom subnets is output here.

>**elastic_search_deployments**, information on the Elastic Search deployments, mainly their Google Cloud internal load balancers IP addresses, see also submodule [documentation](modules/elasticsearch).

>**clickhouse_deployments**, information on the Clickhouse deployments, mainly their Google Cloud internal load balancers IP addresses, see also submodule [documentation](modules/clickhouse)

>**api_deployments**, output information from the _API submodule_ is forwarded here, see also submodule [documentation](modules/api)

>**webapp_deployment**, output information from the _webapp submodule_ is forwarded here, see also submodule [documentation](modules/webapp)

>**debug_glb_platform**, details on the deployed platform GLB are provided through this output parameter.

>**dns_records**, provides the details about the created DNS records.

>**inspection_vms**, this output parameter offers information about the inspection VMs deployed within the infrastructure.

#### Disclaimer
Infrastructure visual diagrams use AWS icons and visual elements, but their meaning in Open Targets Google Cloud Infrastructure is the same, from the conceptual point of view.

# Copyright
Copyright 2014-2018 Biogen, Celgene Corporation, EMBL - European Bioinformatics Institute, GlaxoSmithKline and Wellcome Sanger Institute

This software was developed as part of the Open Targets project. For more information please see: http://www.opentargets.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
