# Open Targets Platform Prometheus
This submodule defines the infrastructure needed to deploy Open Targets Platform Prometheus and Grafana Server.

![Open Targets Platform Prometheus, Deployment Unit](../../docs/img/open_targets_platform_infrastructure.svg "Open Targets Platform Prometheus, Deployment Unit")

The picture above these lines represents the Open Targets Platform Prometheus and Grafana elements defined by this infrastructure definition.

VM instances running the Open Targets Platform Prometheus and Grafana services are configured in a regional instance group, deployed in the given regions, and tagged accordingly, with the option of having an internal load balancer or global load balancer at front, or none of them.

# How to use the module
The module can be sourced from its GitHub URL as shown below.
```terraform
// --- Open Targets Platform Prometheus and Grafana --- //
module "backend_prometheus" {
  source = "github.com/opentargets/terraform-google-opentargets-platform//modules/prometheus"
  // ...
}
```

# Module configuration
The module implements the following input parameters.

## General configuration
>**module_wide_prefix_scope**, scoping prefix for resources names deployed by this module, default 'otpdevprometheus'.

>**module_wide_prefix_es** Scoping prefix for resources from elastisearch module. This value is used to filter for the OpenSearch resources that will be scraped by Prometheus monitoring.

>**module_wide_prefix_ch** Scoping prefix for resources from elastisearch module. This value is used to filter for the ClickHouse resources that will be scraped by Prometheus monitoring.

>**module_wide_prefix_api** Scoping prefix for resources from elastisearch module. This value is used to filter for the API resources that will be scraped by Prometheus monitoring.

>**config_release_name** Open Targets Platform release name. Used to filter to select only the resources related to the specific release.

>**project_id**, ID of the project where resources should be deployed.

>**network_name**, name of the network where resources should be connected to, default 'default'.

>**network_self_link**, self link to the network where resources should be connected when deployed.

>**network_subnet_name**, name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'.

>**network_sources_health_checks**, source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]', which are the source CIDRs used by Google Cloud infrastructure.

## Prometheus instances configuration
>**deployment_regions**, list of regions where the Prometheus nodes should be deployed.

>**vm_firewall_tags**, list of additional tags to attach to Prometheus nodes.

>**vm_prometheus_vcpus**, CPU count for Prometheus nodes, default '2'.

>**vm_prometheus_mem**, amount of memory allocated for Prometheus nodes (MiB), default '7680'.

>**vm_prometheus_image**, VM image to use for Prometheus nodes, default 'debian-12-bookworm-v20250415'.

>**vm_prometheus_image_project**, project hosting the VM image, default 'debian-cloud'.

>**vm_prometheus_boot_disk_size**, boot disk size for Prometheus nodes, default '50GB'.

>**deployment_target_size**, initial Prometheus node count per region.

>**common_tags** List of common tags to attach to resources


## Load Balancer configuration
>**load_balancer_type**, this will tell the module whether an internal load balancer, a global load balancer, or no load balancer at all should be created. Valid values are: 'INTERNAL', 'GLOBAL' (**UNDER REVIEW, DO NOT USE**), 'NONE'.

## Git Repository
>**git_branch** Git branch in which the resources will be available. This variable is made available in case the changes are not in the default branch.

>**git_repository** Git repository that stores the Prometheus and Grafana module. This repository contains cofiguration files used to start the containers and pre configure Grafana.

# Output Information
Once the infrastructure has been successfully deployed, the following details are revealed by this module as output.

>**deployment_regions**, a list of regions where Prometheus nodes have been deployed.

>**map_region_to_instance_group_manager**, for every region, Prometheus nodes are deployed within a managed regional instance group, and this map provides a per region reference to every deployed instance group.

>**prometheus_port**, Open Targets Platform Prometheus listening port.

>**prometheus_port_name**, named port corresponding to Open Targets Platform Prometheus listening port

>**ilb_ip_addresses**, a map from region to the corresponding deployed internal load balancer, in case 'INTERNAL' was chosen as the load balancer option.

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