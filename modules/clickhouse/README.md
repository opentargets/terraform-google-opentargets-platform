# Open Targets Platform Elastic Search Data Backend
This submodule defines the infrastructure needed to deploy a Clickhouse based data backend, within the context of Open Targets Platform.

![Open Targets Platform Clickhouse, Deployment Unit](../../docs/img/open_targets_platform_clickhouse.png "Open Targets Platform Clickhouse, Deployment Unit")

The picture above these lines represents a deployment unit of Open Targets Platform Clickhouse data backend.

VM instances running the Clickhouse services are configured in a regional instance group, deployed in the given region, behind an internal load balancer.

# How to use the module
The module can be sourced from its GitHub URL as shown below.
```terraform
// --- Elastic Search Backend --- //
module "backend_elastic_search" {
  source = "github.com/opentargets/terraform-google-opentargets-platform//modules/clickhouse"
  // ...
}
```

# Module configuration
The module implements the following input parameters.

## General configuration
>**module_wide_prefix_scope**, the prefix provided here will scope names for those resources created by this module, default 'otpdevch'.

>**network_name**, name of the network resources will be connected to, default 'default'.

>**network_self_link**, self link to the network where resources should be connected when deployed, default 'default'.

>**network_subnet_name**, name of the subnet, within the 'network_name', and the given region, where instances should be connected to, default 'main-subnet'.

>**network_source_ranges**, CIDR that represents which IPs we want to grant access to the deployed resources, default '10.0.0.0/9'.

>**network_sources_health_checks**, source CIDR for health checks, default '[ 130.211.0.0/22, 35.191.0.0/16 ]'.

>**deployment_region**, region where resources should be deployed.


## Clickhouse configuration
>**vm_firewall_tags**, additional tags to attach to deployed Clickhouse nodes, by default, no additional tags will be attached.

>**vm_clickhouse_vcpus**, CPU count for Clickhouse instances, default '4'

>**vm_clickhouse_mem**, amount of memory allocated for Clickhouse instances (MiB), default '26624'.

>**vm_clickhouse_image**, VM image to use for Clickhouse nodes.

>**vm_clickhouse_image_project**, ID of hosting project for Clickhouse VM image.

>**vm_clickhouse_boot_disk_size**, Clickhouse VM boot disk size, default '250GB'.

>**deployment_target_size**, This number configures how many instances should be running, default '1'.

# Output Information
Once the infrastructure has been successfully deployed, the following details are revealed by this module as output.

>**deployment_region**, region where resources have been deployed.

>**network_name**, VPC network where resources have been connected to.

>**network_subnet_name**, VPC Subnet within the given region where resources have been connected to.

>**ilb_ip_address**, IP address of the deployed Internal Load Balancer that is at front of the Clickhouse VMs.

>**port_clickhouse_http**, Clickhouse HTTP requests port.

>**port_clickhouse_http_name**, named port corresponding to Clickhouse HTTP requests port.

>**port_clickhouse_cli**, Clickhouse client port.

>**port_clickhouse_cli_name**, named port corresponding to Clickhouse client port.

