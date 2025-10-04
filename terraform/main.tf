locals {
  vms_by_host = {
    for vm in var.host_vms : vm.host_key => vm...
  }
}

module "host1" {
  source = "./modules/hyperv-host"

  providers = {
    hyperv = hyperv.host1
  }

  host_config    = var.hyperv_hosts["host1"]
  vms            = local.vms_by_host["host1"]
  iso_path       = var.iso_path
  cluster_switch = var.switch
  production     = var.production
}

# Combine outputs from all hosts
locals {
  all_vm_infos = module.host1.vms
}
