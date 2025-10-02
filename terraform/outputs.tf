# validation_results: map of host name -> validation output (true/false) 
output "validation_results" {
  value = {
    "host1" = module.validate_host1.validation_output
  }
  description = "The validation output for each Hyper-V host."
}

# vm_ip_map: map of VM name -> ip (we rely on the ip field in input to be authoritative)
output "vm_ip_map" {
  value = { for vm in local.all_vm_infos : vm.name => vm.ip }
  description = "Map of VM name -> static IP used for Talos configs (authoritative)."
}

# Also output ordered list of controlplane VM names (for bootstrap order)
output "controlplane_names" {
  value = [for vm in local.all_vm_infos : vm.name if vm.role == "controlplane"]
}

output "worker_names" {
  value = [for vm in local.all_vm_infos : vm.name if vm.role == "worker"]
}
