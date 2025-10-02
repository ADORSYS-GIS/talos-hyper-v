terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
  }
}

provider "hyperv" {
  for_each        = var.hyperv_hosts
  alias           = each.key
  user            = each.value.user
  password        = each.value.password
  host            = each.value.host
  port            = each.value.port
  https           = each.value.https
  insecure        = each.value.insecure
  use_ntlm        = each.value.use_ntlm
  tls_server_name = each.value.tls_server_name
  script_path     = each.value.script_path
  timeout         = each.value.timeout
}
