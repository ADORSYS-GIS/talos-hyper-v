module "validate_host" {
  source = "../validate-host"

  production      = var.production
  host            = var.host_config.host
  port            = var.host_config.port
  https           = var.host_config.https
  user            = var.host_config.user
  password        = var.host_config.password
  use_ntlm        = var.host_config.use_ntlm
  cert_thumbprint = "" # This needs to be properly handled if production is true
}

module "vms" {
  source   = "../hyperv-vm"
  for_each = { for vm in var.vms : vm.name => vm }

  providers = {
    hyperv = hyperv
  }

  vm             = each.value
  iso_path       = var.iso_path
  cluster_switch = var.cluster_switch

  depends_on = [module.validate_host]
}

locals {
  all_vm_infos = [for vm in module.vms : vm.vm]
}