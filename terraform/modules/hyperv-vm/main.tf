locals {
  # deterministic MAC generation fallback: stable per VM name
  mac = coalesce(var.vm.mac, format("00:15:5d:%s:%s:%s",
    substr(md5(var.vm.name), 0, 2),
    substr(md5(var.vm.name), 2, 2),
    substr(md5(var.vm.name), 4, 2)
  ))
  disk_path = "${var.disk_dir_path}\\${var.vm.name}.vhdx"
}

resource "hyperv_vhd" "disk" {
  path     = local.disk_path
  size     = var.vm.disk_gb * 1024 * 1024 * 1024
  vhd_type = "Dynamic"
}

resource "hyperv_machine_instance" "vm" {
  name                 = var.vm.name
  generation           = 2
  memory_startup_bytes = var.vm.memory * 1024 * 1024 # Convert MB to Bytes
  processor_count      = var.vm.cpus
  static_memory        = true # Assuming static memory for simplicity, can be made variable

  depends_on = [hyperv_vhd.disk]

  lifecycle {
    ignore_changes = all
  }

  network_adaptors {
    name               = "${var.vm.name}-nic"
    switch_name        = var.cluster_switch
    static_mac_address = local.mac
  }

  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = var.iso_path
  }

  hard_disk_drives {
    controller_number   = 0
    controller_location = 0
    path                = local.disk_path
  }

  vm_firmware {
    enable_secure_boot = "Off"
    boot_order {
      boot_type           = "DvdDrive"
      controller_number   = 0
      controller_location = 1
    }
    boot_order {
      boot_type           = "HardDiskDrive"
      controller_number   = 0
      controller_location = 0
    }
  }
}
