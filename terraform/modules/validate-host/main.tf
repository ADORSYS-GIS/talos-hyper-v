resource "null_resource" "validate_winrm" {
  provisioner "local-exec" {
    command = "${path.root}/../scripts/check-winrm.sh -TargetHost ${var.host} -Port ${var.port} -User ${var.user} -Password '${var.password}' ${var.https ? "-Https" : ""} ${var.use_ntlm ? "-UseNtlm" : ""} ${var.production ? "-Production" : ""} -CertThumbprint '${var.cert_thumbprint}'"
  }
}
