output "validation_output" {
  value       = data.powershell_script.validate_winrm.stdout
  description = "Output from the WinRM validation script."
}