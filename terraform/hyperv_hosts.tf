module "hyperv-host01" {
  source = "./modules/hyperv-host"

  host_config    = var.hyperv_hosts["host01"]
  vms            = local.vms_by_host["host01"]
  cluster_switch = var.switch
  iso_paths = {
    for k, s in local.iso_name_suffix : k => "${var.iso_prefix_path}/${s}"
  }
}

locals {
  host_modules = [module.hyperv-host01]
}


