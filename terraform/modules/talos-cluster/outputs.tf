output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}

output "talosconfig" {
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
  description = "The generated talosconfig for the cluster."
}
