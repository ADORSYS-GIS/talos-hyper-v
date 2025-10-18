output "iso_urls" {
  value = {
    for ip in var.machines_ips : ip => data.talos_image_factory_urls.this[ip].urls.iso_secureboot
  }
  description = "The URL of the generated Talos secure boot ISO image."
}

output "schematic_ids" {
  value = {
    for ip in var.machines_ips : ip => talos_image_factory_schematic.this[ip].id
  }
  description = "The ID of the generated Talos schematic."
}

output "talos_installers" {
  value = {
    for ip in var.machines_ips : ip => data.talos_image_factory_urls.this[ip].urls.installer_secureboot
  }
  description = "The Talos installer image URL."
}
