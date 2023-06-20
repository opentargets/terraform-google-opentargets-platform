// --- Security Layer --- //

// This layer defines deployment-wide security settings.

// By default, API and Web security policies are enabled --- //
// As this infrastructure definition is shared by Platform and Partner Platform, we enable security by default
// CIDR block default profile, 'netsec_cidr.default'

// config_security_api_enable    = false
// config_security_webapp_enable = false
// config_security_restrict_source_ips_cidrs_file = "netsec_cidr.default"