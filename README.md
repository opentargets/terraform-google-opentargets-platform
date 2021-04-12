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
- **TODO** Step, clone the repository
- **TODO** Talk about the Makefile helper
- **TODO** Deployment process
   - **TODO** Step, set the active terraform environment
   - **TODO** Step, set the active deployment context
   - **TODO** Step, terraform plan analysis
   - **TODO** Step, terraform apply

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