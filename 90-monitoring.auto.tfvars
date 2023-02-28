// --- Monitoring layer --- //

// This file defines the baseline configuration for the monitoring layer on the deployed infrastructure

// Development facilities //

// Development mode will enable the following features:
// - SSH access to deployed instances
config_set_dev_mode_on = true

// Inspection will enable the following features:
// - An SSH enabled instance within the same VPC as the deployed instances, for every deployed region
//config_enable_inspection                    = true
