output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}

output "talosconfig" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = false
  description = "The generated talosconfig for the cluster."
}
