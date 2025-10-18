locals {
  vms_macs = {
    for vm in var.host_vms : vm.ip => coalesce(vm.mac, format("00:15:5d:%s:%s:%s",
      substr(md5(vm.name), 0, 2),
      substr(md5(vm.name), 2, 2),
      substr(md5(vm.name), 4, 2)
    ))
  }

  vms_by_host = {
    for vm in var.host_vms : vm.host_key => vm...
  }
  
  iso_name_suffix = {
    for vm in var.host_vms : vm.ip => "talos-${vm.ip}.iso"
  }

  cluster_endpoint = "https://${var.talos_vip}:6443"
}
