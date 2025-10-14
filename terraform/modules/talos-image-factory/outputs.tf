output "iso_url" {
  value       = data.talos_image_factory_urls.this.urls.iso_secureboot
  description = "The URL of the generated Talos secure boot ISO image."
}

output "schematic_id" {
  value       = talos_image_factory_schematic.this.id
  description = "The ID of the generated Talos schematic."
}

output "talos_installer" {
  value       = data.talos_image_factory_urls.this.urls.installer_secureboot
  description = "The Talos installer image URL."
}
