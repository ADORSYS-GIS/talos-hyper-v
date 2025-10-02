output "vm" {
  value = {
    name = var.vm.name
    ip   = var.vm.ip
    role = var.vm.role
    mac  = local.mac
  }
}
