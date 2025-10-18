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

output "talosconfig" {
  value       = module.talos_cluster.talosconfig
  sensitive   = true
  description = "The generated talosconfig for the cluster."
}

output "talos_iso_urls" {
  value       = module.talos_image_factory.iso_urls
  description = "The URL of the generated Talos ISO image."
}

output "talos_iso_urls_download_commands_powershell" {
  value = [
    for k, v in module.talos_image_factory.iso_urls :
    "Invoke-WebRequest ${v} -OutFile ${local.iso_name_suffix[k]}"
  ]

  description = "The URL of the generated Talos ISO image."
}

output "talos_schematic_ids" {
  value       = module.talos_image_factory.schematic_ids
  description = "The ID of the generated Talos schematic."
}
