# Introduction
**TODO** - General Introduction to what is Open Targets Platform

## Infrastructure definition
This repository defines the Open Targets Platform infrastructure, using Hashicorp Configuration Language (HCL) and [Terraform](https://terraform.io).

![Open Targets Platform, Deployment Unit](docs/img/open_targets_platform_infrastructure.png "Open Targets Platform, Deployment Unit")

As shown in the figure above, a deployment unit consists of two data backends, based on Elastic Search and Clickhouse services. Set to automatically scale up on demand and self-heal, as part of the managing activities in their scoping regional instance group.

These services are accessible by the backend API via their respective Internal Load Balancers, which not only distributes the requests among available instances, but also prevents a broken instance from receiving any traffic.

Open Targets platform API services are deployed as a collection of instances in a regional group, set behind a Global Load Balancer, that serves requests from the internet to these services via HTTP and HTTPS, being SSL terminated at this infrastructure entry point.

The platform web frontend is deployed in a Google Cloud Storage Bucket, not shown in the picture above, that is also behind this Global Load Balancer.

We use Google Cloud DNS services for all domain names deployed via this infrastructure definition.

## FAIR Principles
Open Targets Platform Infrastructure has been defined using [Terraform Modules](https://www.terraform.io/docs/language/modules/develop/index.html).

The platform has been broken down into the following components:
- [Clickhouse](modules/clickhouse)
- [Elastic Search](modules/elasticsearch)
- API
- Web frontend

Each component is defined and encapsulated as a submodule that can be reused independently, in any Google Cloud environment run, or not, by Open Targets.

These modules are accessible by the community via our Open Source license, as well as their underlying machine images (via their corresponding licenses).

This repository itself makes use of them as a Terraform Root Module, to build what constitutes Open Targets Platform. In addition, this root module is also available to the community via our Open Source license, thus, anyone can use it for deploying the platform in any Google Cloud project environment.

This also simplifies our development, testing, QA and staging workflows internally at Open Targets, by doing a lot of heavy lifting for our backend and frontend engineers.

# Open Targets Platform Deployment Process
Prior to working with this infrastructure definition, you need to make sure that you have:
- _Terraform_ v0.14.5 or later
- _Google Cloud SDK_ 333.0.0 or later, with valid credentials
- _Makefile_ enabled environment, with common command line tools, e.g. sed

Clone the repository, if you have GitHub Cli:
```
$ gh repo clone opentargets/terraform-google-opentargets-platform
```

## Terraform State
Terraform uses a [state file](https://www.terraform.io/docs/language/state/index.html) that allows it to track the managed infrastructure.

The information is stored in a file, and this file can reside in the local file system, or somewhere else, e.g. a Google Cloud Bucket.

This is known as _Terraform backend_, and, by default, when you clone this repository, the active backend is _local_, which means the Terraform state will be stored in the local filesystem.

## Makefile Helper
This infrastructure definition includes a _Makefile_ helper that implements the available operations for working with the defined infrastructure.

## How to make a deployment?
### First Step, Terraform Environment
The first step is to activate a _Terraform Environment_, which will contain, among other things, the details related to the _Terraform backend_ that will be used.

```
$ make tfactivate profile=your_terraform_environment_profile_name

# As an example, to activate mbdev profile
$ make tfactivate profile=mbdev
```

In case you need to create your own profile, please see instructions [here](#tfcreate)

### Second Step, Terraform Backend
Once you have an active _Terraform Environment_, we recommend using a remote backend (required for production and shared deployment projects), which can be activated via the following command
```
$ make tfbackendremote
```

### Third Step, Activate the corresponding Deployment Context
Once the _Terraform backend_ to be used is set, we need to "select" which deployment context we want this module to use for planning our infrastructure deployment.

All _Deployment Contexts_ are deposited in the _profiles_ folder, see [here](#depcontextexplained) for more details.

To activate a context, e.g. 'dev202102', use the following command
```
$ make depactivate profile=dev202102
```

The active _Deployment Context_ will be made available at the root of this _Terraform_ module, file name _deployment_context.tfvars_, you can manipulate this file and make changes to the resources that _Terraform_ will deploy, without affecting the original profile. This is particularly useful in development environments, although we don't recommend this operational approach in production.

### Fourth Step, Terraform command wrappers
Now we have all the information we need, we can start using _Terraform_, via the command wrappers described below, but, before that, we need to initialize _Terraform_, so it will download the necesary plugins, modules, etc.
```
$ make tfinit
```

**Terraform Plan** command wrapper
```
$ make tfplan
```
This will prompt _Terraform_ to calculate a deployment plan according to the current state and the requested deployment definition

**Terraform Apply** command wrapper
```
$ make tfapply
```
This command will show the _Terraform_ calculated plan, as in _make tfplan_, and will ask for confirmation on the proposed changes to the current infrastructure, if any.

**Terraform Destroy** command wrapper
```
$ make tfdestroy
```
This command will destroy all the deployed resources, according to the state in the configured backend.

USE ONLY in development environments.

<a name="depcontextexplained"></a>

# Deployment Context Explained
A deployment context is a collection of input parameters that defines how Open Targets Platform will be brought up to life.

The following sample deployment context will be used for explaining the different parameters:
```terraform
// --- Sample deployment ---//
// --- Release information --- //
config_release_name                         = "mbotp"
// --- Deployment configuration --- //
config_gcp_default_region                   = "europe-west1"
config_gcp_default_zone                     = "europe-west1-b"
config_project_id                           = "open-targets-eu-dev"
config_deployment_regions                   = [ "europe-west2" ]
// --- Elastic Search configuration --- //
config_vm_elastic_search_image_project      = "open-targets-platform"
config_vm_elastic_search_vcpus              = "4"
config_vm_elastic_search_mem                = "26624"
config_vm_elastic_search_image              = "platform-etl-21-02-es"
config_vm_elastic_search_version            = "7.9.0"
config_vm_elastic_search_boot_disk_size     = "500GB"
// --- Clickhouse configuration --- //
config_vm_clickhouse_vcpus                  = "4"
config_vm_clickhouse_mem                    = "26624"
config_vm_clickhouse_image                  = "clickhouse-ot-platform-ch-21-02"
config_vm_clickhouse_image_project          = "open-targets-platform"
config_vm_clickhouse_boot_disk_size         = "250GB"
// --- API configuration --- //
config_vm_platform_api_image_version        = "0.55.8"
config_vm_api_vcpus                         = "2"
config_vm_api_mem                           = "7680"
config_vm_api_image                         = "cos-stable"
config_vm_api_image_project                 = "cos-cloud"
config_vm_api_boot_disk_size                = "10GB"
// --- DNS --- //
config_dns_project_id                       = "open-targets-eu-dev"
config_dns_subdomain_prefix                 = "gamma"
config_dns_managed_zone_name                = "opentargets-xyz"
config_dns_managed_zone_dns_name            = "opentargets.xyz."
config_dns_platform_api_subdomain           = "api"
// --- Web App configuration --- //
config_webapp_repo_name                     = "mbdebian/platform-app"
config_webapp_release                       = "1.0.7"
config_webapp_deployment_context_map        = {
    DEVOPS_CONTEXT_PLATFORM_APP_CONFIG_URL_APOLLO_CLIENT = "'https://api.platform.gamma.opentargets.xyz/api/v4/graphql'"
}
// --- Development Mode --- //
config_set_dev_mode_on                      = true
//config_enable_inspection                    = true
```

## Release Information
This section groups together metaparameters related to the deployment that will be used, among other things, for scoping resources IDs / names.

>**config_release_name**, its value will be used for prefix-scoping names / IDs of deployed resources

## Deployment configuration
The details in this section define parameters related to the destination Google Cloud Project and regions, where resources will be created.

>**config_gcp_default_region**, default deployment region when no region is specified, this parameters is related to the cloud provider configuration, in this case Google Cloud Platform.

>**config_gcp_default_zone**, default deployment zone when no zone is specified, this parameters is related to the cloud provider configuration, in this case Google Cloud Platform.

>**config_project_id**, Google Cloud Project ID that will be the destination for deployed resources.

>**config_deployment_regions**, a list of Google Cloud regions for deploying Open Targets Platform across.

## Elastic Search configuration
On this section, the deployment context defines which Elasctic Search backend will be deployed.

>**config_vm_elastic_search_image_project**, VM images may be hosted in a project different than the recipient of the resources being deployed, which ID is specified here.

>**config_vm_elastic_search_vcpus**, CPU count to be allocated for every Open Targets Elastic Search instance.

>**config_vm_elastic_search_mem**, amount of memory to be allocated for every Open Targets Elastic Search instance (MiB).

>**config_vm_elastic_search_image**, VM image ID for Open Targets Elastic Search instances.

>**config_vm_elastic_search_version**, Docker image version for running Elastic Search within the VM isntances.

>**config_vm_elastic_search_boot_disk_size**, VM boot disk size to attach to the Open Targets Elastic Search instances.

## Clickhouse configuration
This deployment context section defines the Clickhouse backend that will be deployed.

>**config_vm_clickhouse_vcpus**, CPU count to be allocated for every Open Targets Clickhouse instance.

>**config_vm_clickhouse_mem**, amount of memory to be allocated for every Open Targets Clickhouse instance (MiB).

>**config_vm_clickhouse_image**, VM image ID for Open Targets Clickhouse instances.

>**config_vm_clickhouse_image_project**, VM images may be hosted in a project different than the recipient of the resources being deployed, which ID is specified here.

>**config_vm_clickhouse_boot_disk_size**, VM boot disk size to attach to the Open Targets Clickhouse instances.

## API configuration
Like on the previous sections, this one contains a collection of _Terraform input parameters_ that configure which Open Targets Platform API will be deployed.

>**config_vm_platform_api_image_version**, Open Targets Platform API image version to deploy.

>**config_vm_api_vcpus**, CPU count to be allocated for every Open Targets Platform API instance.

>**config_vm_api_mem**, amount of memory to be allocated for every Open Targets Platform API instance (MiB).

>**config_vm_api_image**, VM image ID for Open Targets Platform API instances.

>**config_vm_api_image_project**, VM images may be hosted in a project different than the recipient of the resources being deployed, which ID is specified here.

>**config_vm_api_boot_disk_size**, VM boot disk size to attach to the Open Targets Platform API instances.

## Web Application configuration
Another software component of Open Targets Platform is its web frontend, and this section shapes its deployment.

A web application bundle is used for deploying the web frontend SPA, obtained as an asset attached to the specified GitHub release.

>**config_webapp_repo_name**, GitHub repository where to fetch the bundle from.

>**config_webapp_release**, GitHub tag release.

>**config_webapp_deployment_context_map**, this is a simple key-value collection that will be injected as configuration in the web application when deployed.

## DNS configuration
Some of the resources that are part of Open Targets Platform will be attending external requests, e.g. the platform API, and they need to get registered under their corresponding DNS entries.

This section shapes how those DNS entries are set.

>**config_dns_project_id**, ID of the Google Cloud Project that hosts the Cloud DNS services where DNS entries will be registered.

>**config_dns_managed_zone_name**, name of the Cloud DNS managed zone where entries can be registered. 

>**config_dns_subdomain_prefix**, if supplied, this parameters allows for the resources be "scoped" within a subdomain in the DNS, this way, multiple deployments can share the main root domain name.

>**config_dns_managed_zone_dns_name**, root domain name associated to the managed DNS zone.

>**config_dns_platform_api_subdomain**, which subdomain to use fot Open Targets Platform API services, default is 'platform'.

## Development Section
This part of the deployment context is related to some features of the infrastructure definition mainly useful in a development environment.

>**config_set_dev_mode_on**, when development mode is active, SSH traffic to all deployed VMs is enabled, and inspection VMs are deployed.

>**config_enable_inspection**, when true, an extra VM per region will be deployed, for internal access to deployed infrastructure.

# Output Information
Once the deployment process has been successfully completed, the following details about the resources are revealed.

>**network_region_subnet_mapping**, a custom VPC is created for every deployment context of Open Targets Platform, and, as a result, information on the created custom subnets is output here.

>**elastic_search_deployments**, information on the Elastic Search deployments, mainly their Google Cloud internal load balancers IP addresses, see also submodule [documentation](modules/elasticsearch).

>**clickhouse_deployments**, information on the Clickhouse deployments, mainly their Google Cloud internal load balancers IP addresses, see also submodule [documentation](modules/clickhouse)

>**api_deployments**, output information from the _API submodule_ is forwarded here.

>**webapp_deployment**, output information from the _webapp submodule_ is forwarded here.

>**debug_glb_platform**, details on the deployed platform GLB are provided through this output parameter.

>**dns_records**, provides the details about the created DNS records.

>**inspection_vms**, this output parameter offers information about the inspection VMs deployed within the infrastructure.


<a name="tfenvexplained"></a>

# Terraform Environment Explained
Currently, a _Terraform Environment_ profile contains the details that will be used for configuring a remote _Terraform Backend_, which will be used for storing the information related to _Terraform State_.
```
# This is a template Terraform Environment Configuration for creating new profiles
TF_VAR_config_tf_backend_bucket_name='TF_CONFIG_TFSTATE_BUCKET_NAME'

# Usually your GitHub handle without the '@'
TF_VAR_config_tf_backend_prefix='TF_CONFIG_TFSTATE_PREFIX'
```
_TF_VAR_config_tf_backend_bucket_name_ represents the Google Cloud bucket name.

_TF_VAR_config_tf_backend_prefix_ is a prefix that will effectively turn into a folder in the given bucket, storing _Terraform State_ information.

# Other Operations

<a name="tfcreate"></a>

## Creating a Terraform Environment Profile
These profiles are based on templates that can be found in the _profiles_ folder.

Two templates are currently available:
1. _tfenv.template.eudev_, used for creating profiles that will use Open Targets Development environment.
2. _tfenv.template.platform_, used for creating profiles for deployment in our platform project.

There is a third file, _tfenv.template_, which is a "master" template, that can derive custom templates outside the scope of the helpers included with this infrastructure definition.

As an example, creating a _Terraform Environment_ profile called 'mydev', in our development environment, can be done via the following command:
```
$ make tfcreate srcprofile=eudev dstprofile=mydev
```

For more details on _Terraform Environment_, please see [here](#tfenvexplained)

## Cleaning up Terraform Environment
Active _Terraform Environment_ can be cleaned up by the following command:
```
$ make clean tfprofile
```

## Setting Terraform Backend back to 'local'
Setting _Terraform_ backend back to 'local' is, effectively, resetting to default configuration.

There are two targets within the Makefile helper for this purpose:
```
$ make tfbackendlocal
```
or
```
$ make clean_tfbackend
```

## Cleaning up Deployment Context
This action deactivates any currently active deployment context, thus, _Terraform_ has nothing to do.
```
$ make clean_depcontext
```

## Cleaning Everything
This action resets everything to default by removing any active _Terraform Environment_, _Deployment Context_ and setting the backend to 'local'.
```
$ make clean
```

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