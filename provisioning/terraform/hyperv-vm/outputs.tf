output "vms" {
  value = [for vm in var.vms : { name = vm.name, ip = vm.ip, role = vm.role, mac = lookup(vm, "mac", "") }]
}
