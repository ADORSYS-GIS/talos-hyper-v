module "host1_vms" {
  source         = "./hyperv-vm"
  providers      = { hyperv = hyperv.host1 }
  vms            = lookup(var.vms_by_host, "host1", [])
  iso_path       = var.iso_path
  cluster_switch = var.switch
}

# If you have a second host, add:
# module "host2_vms" {
#   source = "./modules/hyperv-vm"
#   providers = { hyperv = hyperv.host2 }
#   vms = lookup(var.vms_by_host, "host2", [])
#   iso_path = var.hyperv_hosts["host2"].iso_path
#   mgmt_switch = var.mgmt_switch_name
# }

# Combine outputs
locals {
  all_vm_infos = try(module.host1_vms.vms, []) # Concatenate VM info from all hosts
}

resource "hyperv_network_switch" "cluster_switch" {
  provider          = hyperv.host1
  name              = var.switch
  switch_type       = "External"
  net_adapter_names = [var.net_adapter_name]
  enable_iov        = true
}

resource "hyperv_vhd" "webserver" {
  provider = hyperv.host1
  path     = "C:/Hyper-V/${var.vhd_name}"
  size     = var.vhd_size_gb * 1024 * 1024 * 1024
}
