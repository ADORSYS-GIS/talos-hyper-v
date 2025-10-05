# vm_ip_map: map of VM name -> ip (we rely on the ip field in input to be authoritative)
output "vm_ip_map" {
  value       = { for vm in var.host_vms : vm.name => vm.ip }
  description = "Map of VM name -> static IP used for Talos configs (authoritative)."
}

# Also output ordered list of controlplane VM names (for bootstrap order)
output "controlplane_names" {
  value = [for vm in var.host_vms : vm.name if vm.role == "controlplane"]
}

output "worker_names" {
  value = [for vm in var.host_vms : vm.name if vm.role == "worker"]
}

output "kubeconfig" {
  value       = module.talos_cluster.kubeconfig
  sensitive   = true
  description = "The generated kubeconfig for the cluster."
}

# output "schematic_id" {
#   value = module.talos_image_factory.schematic_id
# }

# output "installer_image" {
#   value = module.talos_image_factory.installer_url
# }
