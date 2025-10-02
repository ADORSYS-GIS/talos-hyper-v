module "validate_host" {
  source   = "./modules/validate-host"
  for_each = var.hyperv_hosts

  host            = each.value.host
  port            = each.value.port
  https           = each.value.https
  user            = each.value.user
  password        = each.value.password
  use_ntlm        = each.value.use_ntlm
  production      = each.value.production
  cert_thumbprint = each.value.cert_thumbprint
}

module "vms" {
  source   = "./modules/hyperv-vm"
  for_each = { for k, v in var.vms_by_host : k => v if length(v) > 0 }

  providers = {
    hyperv = hyperv[each.key]
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

resource "hyperv_vhd" "webserver" {
  for_each = { for k, v in var.vms_by_host : k => v if length(v) > 0 }
  provider = hyperv[each.key]
  path     = "C:/Hyper-V/${var.vhd_name}"
  size     = var.vhd_size_gb * 1024 * 1024 * 1024
}
