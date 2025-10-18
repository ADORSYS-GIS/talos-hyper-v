locals {
  disk_path = "${var.disk_dir_path}\\${var.name}.vhdx"
  storage_disk_path = var.storage_disk_gb != null ? "${var.disk_dir_path}\\${var.name}-storage.vhdx" : null
}

resource "hyperv_vhd" "disk" {
  path     = local.disk_path
  size     = var.disk_gb * 1024 * 1024 * 1024
  vhd_type = "Dynamic"
}

resource "hyperv_vhd" "storage_disk" {
  count    = var.storage_disk_gb != null ? 1 : 0
  path     = local.storage_disk_path
  size     = var.storage_disk_gb * 1024 * 1024 * 1024
  vhd_type = "Dynamic"
}

resource "hyperv_machine_instance" "vm" {
  name                 = var.name
  generation           = 2
  memory_startup_bytes = var.memory * 1024 * 1024 # Convert MB to Bytes
  processor_count      = var.cpus
  static_memory        = true # Assuming static memory for simplicity, can be made variable

  depends_on = [hyperv_vhd.disk, hyperv_vhd.storage_disk]

  lifecycle {
    ignore_changes = all
  }

  network_adaptors {
    name               = "${var.name}-nic"
    switch_name        = var.cluster_switch
    static_mac_address = var.mac
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

  dynamic "hard_disk_drives" {
    for_each = var.storage_disk_gb != null ? [1] : []
    content {
      controller_number   = 0
      controller_location = 2
      path                = local.storage_disk_path
    }
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
