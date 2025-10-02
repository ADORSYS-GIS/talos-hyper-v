module "validate_host" {
  source = "./modules/validate-host"

  production      = var.production
  host            = var.hyperv_host.host
  port            = var.hyperv_host.port
  https           = var.hyperv_host.https
  user            = var.hyperv_host.user
  password        = var.hyperv_host.password
  use_ntlm        = var.hyperv_host.use_ntlm
  cert_thumbprint = each.value.cert_thumbprint
}

module "vms" {
  source   = "./modules/hyperv-vm"
  for_each = { for k, v in var.var.host_vms : k => v if length(v) > 0 }

  providers = {
    hyperv = hyperv
  }

  vms            = each.value
  iso_path       = var.iso_path
  cluster_switch = var.switch

  depends_on = [module.validate_host]
}

# Combine outputs
locals {
  all_vm_infos = flatten([
    for vms_out in module.vms : vms_out.vms
  ])
}
