output "installer_url" {
  value       = data.talos_image_factory_urls.this.urls.installer
  description = "The URL of the generated Talos installer image."
}

output "schematic_id" {
  value       = talos_image_factory_schematic.this.id
  description = "The ID of the generated Talos schematic."
}