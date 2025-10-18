data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = var.talos_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  count = length(var.machines_ips)

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name,
        }
        extraKernelArgs = [
          "ip=${var.machines_ips[count.index]}::${var.gw_ip}:${var.network_mask}::::::${var.ntp_ip}"
        ]
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  count = length(var.machines_ips)

  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this[count.index].id
  platform      = "metal"
}
