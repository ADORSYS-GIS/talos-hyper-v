data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = var.talos_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  for_each = {for ip in var.machines_ips: ip => ip}

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name,
        }
        extraKernelArgs = [
          "ip=${each.value}::${var.gw_ip}:${var.network_mask}::::::${var.ntp_ip}"
        ]
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  for_each = talos_image_factory_schematic.this

  talos_version = var.talos_version
  schematic_id  = each.value.id
  platform      = "metal"
}
