module "vms" {
  source   = "../hyperv-vm"
  for_each = var.vms

  providers = {
    hyperv = hyperv
  }

  name            = try(each.value.name, var.default_memory)
  mac             = try(each.value.mac, var.vms_macs[each.value.ip])
  memory          = try(coalesce(each.value.memory, var.default_memory))
  cpus            = each.value.cpus
  disk_gb         = each.value.disk_gb
  storage_disk_gb = each.value.storage_disk_gb
  iso_path        = var.iso_paths[each.value.ip]
  cluster_switch  = var.cluster_switch
  disk_dir_path   = try(each.value.disk_dir_path, var.default_disk_dir_path)
}
