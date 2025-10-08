output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}

output "kubernetes_client_configuration" {
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
  description = "The client certificate from the generated kubeconfig."
}


output "talosconfig" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = false
  description = "The generated talosconfig for the cluster."
}
