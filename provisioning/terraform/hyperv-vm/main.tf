locals {
  # deterministic MAC generation fallback: stable per VM name
  macs = [
    for vm in var.vms : lookup(vm, "mac", format("00:15:5d:%02x:%02x:%02x",
      tonumber(substr(md5(vm.name),0,2),16),
      tonumber(substr(md5(vm.name),2,2),16),
      tonumber(substr(md5(vm.name),4,2),16)))
  ]
}

resource "hyperv_virtual_machine" "vm" {
  for_each = { for idx, vm in var.vms : vm.name => merge(vm, { mac = local.macs[idx] }) }

  name           = each.key
  generation     = 2
  memory_startup = lookup(each.value, "memory", 4096)
  cpu_count      = lookup(each.value, "cpus", 2)

  network_adapter {
    switch_name = var.mgmt_switch
    mac_address = each.value.mac
  }

  dvd_drive {
    iso_path = var.iso_path
  }

  hard_disk {
    path = "C:/Hyper-V/${each.key}.vhdx"
    size = lookup(each.value, "disk_gb", 40)
  }

  boot_order {
    boot_device = "DVD"
  }

  # Provider may not populate ip_address; we treat ip from inputs as authoritative.
}
