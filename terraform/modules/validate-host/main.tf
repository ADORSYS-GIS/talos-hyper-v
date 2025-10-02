resource "null_resource" "validate_winrm" {
  provisioner "local-exec" {
    command = "powershell -File ${path.module}/../../scripts/check-winrm.ps1 -Host ${var.host} -Port ${var.port} -Https ${var.https} -UseNtlm ${var.use_ntlm} -User ${var.user} -Password '${var.password}' -Production ${var.production} -CertThumbprint ${var.cert_thumbprint}"
  }
}
