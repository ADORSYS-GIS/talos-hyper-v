terraform {
  required_providers {
    powershell = {
      source  = "hashicorp/powershell"
      version = ">= 1.0"
    }
  }
}

data "powershell_script" "validate_winrm" {
  script = file("${path.module}/../../scripts/check_wirm.ps1")

  vars = {
    Host            = var.host
    Port            = var.port
    Https           = var.https
    UseNtlm         = var.use_ntlm
    User            = var.user
    Password        = var.password
    Production      = var.production
    CertThumbprint  = var.cert_thumbprint
  }
}

output "validation_output" {
  value       = data.powershell_script.validate_winrm.stdout
  description = "Output from the WinRM validation script."
}