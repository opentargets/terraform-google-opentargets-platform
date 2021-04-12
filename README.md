# terraform-google-opentargets-platform
Terraform module for Open Targets Platform infrastructure definition

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

## Infrastructure FAIRness
Open Targets Platform Infrastructure has been defined using [Terraform Modules](https://www.terraform.io/docs/language/modules/develop/index.html).

The platform has been broken down into the following components:
- Clickhouse
- Elastic Search
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

# Deployment Context Explained
<a name="depcontextexplained"></a>
TODO

# Terraform Environment Explained
<a name="tfenvexplained"></a>
TODO

# Other Operations
## Creating a Terraform Environment Profile
<a name="tfcreate"></a>
lkajshdflkjasdhf laksjdhf

## Cleaning up Terraform Environment
TODO

## Setting Terraform Backend back to 'local'
TODO

## Cleaning up Deployment Context
TODO

## Cleaning Everything
TODO

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