// --- Machine Persona Layer --- //

// This layer defines the machine persona for the VM, e.g. provisioning method, maybe labels, etc.

// API node --- //
// By default, we use the development configuration, where the provisioning model for VMs is preemptible.
config_vm_api_flag_preemptible = true
config_vm_prometheus_flag_preemptible = true