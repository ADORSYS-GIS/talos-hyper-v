output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}