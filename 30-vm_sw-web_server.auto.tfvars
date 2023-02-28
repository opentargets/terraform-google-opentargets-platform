// --- Machine Software Layer --- //

// This file defines the software we lay on top of the OS, under the layers that will complete the machine definition.

// Web Server node --- //
// Repository where the provisioner will look for the web application bundle
config_webapp_repo_name = "opentargets/ot-ui-apps"
// This is the nginx image version that will be used to serve the web application
config_webapp_webserver_docker_image_version = "1.21.3"
