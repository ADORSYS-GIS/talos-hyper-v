module "vms" {
  source   = "../hyperv-vm"
  for_each = { for vm in var.vms : vm.name => vm }

  providers = {
    hyperv = hyperv
  }

  vm             = each.value
  iso_path       = var.iso_paths[each.value.ip]
  cluster_switch = var.cluster_switch
}

locals {
  all_vm_infos = [for vm in module.vms : vm.vm]
}