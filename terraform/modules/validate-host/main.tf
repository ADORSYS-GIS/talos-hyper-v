terraform {
  required_providers {
    powershell = {
      source  = "hashicorp/powershell"
      version = ">= 1.0"
    }
  }
}

data "powershell_script" "validate_winrm" {
  script = file("${path.module}/../../scripts/check-winrm.ps1")

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
