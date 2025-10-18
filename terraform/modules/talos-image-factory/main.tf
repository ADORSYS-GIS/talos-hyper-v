data "talos_image_factory_extensions_versions" "this" {
  for_each      = var.machines_configs
  talos_version = var.talos_version
  filters = {
    names = each.value.extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  for_each = var.machines_configs

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this[each.key].extensions_info.*.name,
        }
        extraKernelArgs = [
          "ip=${each.key}::${var.gw_ip}:${var.network_mask}:${each.value.host_name}:enx${each.value.mac_address}::${var.dns_01}:${var.dns_02}:${var.ntp_ip}"
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
