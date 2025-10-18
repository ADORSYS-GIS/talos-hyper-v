module "vms" {
  source   = "../hyperv-vm"
  for_each = var.vms

  providers = {
    hyperv = hyperv
  }

  name    = try(coalesce(each.value.name, var.default_memory))
  mac     = try(coalesce(each.value.mac, var.vms_macs[each.value.ip]))
  memory  = try(coalesce(each.value.memory, var.default_memory))
  cpus    = try(coalesce(each.value.cpus, var.default_cpus))
  disk_gb = each.value.disk_gb
  storage_disk_sizes = {
    for idx in range(2, 2 + length(each.value.storage_disk_sizes)) :
    "storage-disk-${idx}" => {
      size     = each.value.storage_disk_sizes[idx]
      location = idx
    }
  }
  iso_path       = var.iso_paths[each.value.ip]
  cluster_switch = var.cluster_switch
  disk_dir_path  = try(coalesce(each.value.disk_dir_path, var.default_disk_dir_path))
}
