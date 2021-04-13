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