// --- Machine Persona Layer --- //

// This layer defines the machine persona for the VM, e.g. provisioning method, maybe labels, etc.

// Clickhouse node --- //
// By default, we use the development configuration, where the provisioning model for VMs is preemptible.
config_vm_clickhouse_flag_preemptible = true