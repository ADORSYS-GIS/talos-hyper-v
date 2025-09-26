locals {
  # deterministic MAC generation fallback: stable per VM name
  macs = [
    for vm in var.vms : lookup(vm, "mac", format("00:15:5d:%s:%s:%s",
      substr(md5(vm.name), 0, 2),
      substr(md5(vm.name), 2, 2),
      substr(md5(vm.name), 4, 2)))
  ]
}

resource "hyperv_machine_instance" "vm" {
  for_each = { for idx, vm in var.vms : vm.name => merge(vm, { mac = local.macs[idx] }) }

  name               = each.key
  generation         = 2
  memory_startup_bytes = lookup(each.value, "memory", 4096) * 1024 * 1024 # Convert MB to Bytes
  processor_count    = lookup(each.value, "cpus", 2)
  static_memory      = true # Assuming static memory for simplicity, can be made variable

  network_adaptors {
    name        = "${each.key}-nic" # A unique name for the network adapter
    switch_name = var.cluster_switch
    static_mac_address = each.value.mac
  }

  dvd_drives {
    controller_number   = 1
    controller_location = 0
    path                = var.iso_path
  }

  hard_disk_drives {
    controller_number   = 0
    controller_location = 0
    path                = "C:/Hyper-V/${each.key}.vhdx"
  }

  vm_firmware {
    boot_order {
      boot_type = "DvdDrive"
      controller_number = 1
      controller_location = 0
    }
    boot_order {
      boot_type = "HardDiskDrive"
      controller_number = 0
      controller_location = 0
    }
  }
}
