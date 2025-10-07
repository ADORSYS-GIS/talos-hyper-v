module "hyperv-host01" {
  source = "./modules/hyperv-host"

  host_config    = var.hyperv_hosts["host01"]
  vms            = local.vms_by_host["host01"]
  iso_path       = var.iso_path
  cluster_switch = var.switch
  production     = var.production
}

locals {
  host_modules = [module.hyperv-host01]
}


