resource "null_resource" "validate_winrm" {
  provisioner "local-exec" {
    command = "${path.root}/../scripts/check-winrm.sh -TargetHost ${var.host} -User ${var.user} -Password '${var.password}' ${var.https ? "-Https" : ""} ${var.use_ntlm ? "-UseNtlm" : ""} ${var.production ? "-Production" : ""}"
  }
}
