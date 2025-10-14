output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}

output "cluster_ca_certificate" {
  value       = talos_machine_secrets.this.client_configuration.ca_certificate
  sensitive   = true
  description = "The client certificate from the generated kubeconfig."
}

output "cluster_token" {
  value       = talos_machine_secrets.this.machine_secrets.trustdinfo.token
  sensitive   = true
  description = "The token from the generated kubeconfig."
}


output "talosconfig" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = false
  description = "The generated talosconfig for the cluster."
}
