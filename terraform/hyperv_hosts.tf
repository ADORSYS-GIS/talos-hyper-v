module "hyperv-host01" {
  source = "./modules/hyperv-host"

  host_config           = var.hyperv_hosts["host01"]
  cluster_switch        = var.switch
  vms_macs              = local.vms_macs
  default_cpus          = var.default_cpus
  default_memory        = var.default_memory
  default_disk_dir_path = var.disk_dir_path
  vms                   = { for vm in local.vms_by_host["host01"] : vm.name => vm }
  iso_paths = {
    for k, s in local.iso_name_suffix : k => "${var.iso_prefix_path}\\${s}"
  }
}

module "hyperv-host02" {
  source = "./modules/hyperv-host"

  host_config           = var.hyperv_hosts["host02"]
  cluster_switch        = var.switch
  vms_macs              = local.vms_macs
  default_cpus          = var.default_cpus
  default_memory        = var.default_memory
  default_disk_dir_path = var.disk_dir_path
  vms                   = { for vm in local.vms_by_host["host02"] : vm.name => vm }
  iso_paths = {
    for k, s in local.iso_name_suffix : k => "${var.iso_prefix_path}\\${s}"
  }
}

locals {
  host_modules = [module.hyperv-host01, module.hyperv-host02]
}
