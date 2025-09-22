# For each hyperv host in var.hyperv_hosts we create a provider alias
locals {
  host_keys = keys(var.hyperv_hosts)
}

# Dynamically create provider aliases using a for_each and terraform-provider "hyperv" "alias" approach.
# Many Terraform providers can't be created dynamically in a single file; so create provider blocks for common cases.
# For a small fixed set (e.g. host1,host2) you can manually create aliases in providers.tf. For generality, we assume two in examples.
# Example here: the user will add provider aliases in providers.tf for each host alias: hyperv.host1, hyperv.host2, etc.

# Module calls per host (explicit; add more by replicating block or use for_each with module counts)
# We'll assume var.hyperv_hosts contains keys "host1","host2"... user must add provider aliases accordingly.

module "host1_vms" {
  source = "./modules/hyperv-vm"
  providers = { hyperv = hyperv.host1 }
  vms = lookup(var.vms_by_host, "host1", [])
  iso_path = var.hyperv_hosts["host1"].iso_path
  mgmt_switch = var.mgmt_switch_name
}

# If you have a second host, add:
module "host2_vms" {
  source = "./modules/hyperv-vm"
  providers = { hyperv = hyperv.host2 }
  vms = lookup(var.vms_by_host, "host2", [])
  iso_path = var.hyperv_hosts["host2"].iso_path
  mgmt_switch = var.mgmt_switch_name
}

# Combine outputs
locals {
  all_vm_infos = concat(
    try(module.host1_vms.vms, []),
    try(module.host2_vms.vms, [])
  )
}
