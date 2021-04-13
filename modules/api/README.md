# Open Targets Platform API
This submodule defines the infrastructure needed to deploy Open Targets Platform API.

![Open Targets Platform API, Deployment Unit](../../docs/img/open_targets_platform_api.png "Open Targets Platform API, Deployment Unit")

The picture above these lines represents the Open Targets Platform API elements defined by this infrastructure definition.

VM instances running the Open Targets Platform API services are configured in a regional instance group, deployed in the given regions, and tagged accordingly, with the option of having an internal load balancer or global load balancer at front, or none of them.

# How to use the module
The module can be sourced from its GitHub URL as shown below.
```terraform
// --- Open Targets Platform API --- //
module "backend_elastic_search" {
  source = "github.com/opentargets/terraform-google-opentargets-platform//modules/api"
  // ...
}
```

# Module configuration
The module implements the following input parameters.

## General configuration
>**module_wide_prefix_scope**, scoping prefix for resources names deployed by this module, default 'otpdevapi'.

>**project_id**, ID of the project where resources should be deployed.

>**network_name**, name of the network where resources should be connected to, default 'default'.

>**network_self_link**, self link to the network where resources should be connected when deployed.

>**network_subnet_name**, name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'.

>**network_source_ranges_map**, CIDR that represents which IPs we want to grant access to the deployed resources.

>**network_sources_health_checks**, source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]'.
