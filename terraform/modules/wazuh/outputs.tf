output "root_ca_pem" {
  value     = tls_self_signed_cert.root_ca.cert_pem
  sensitive = true
}

output "root_ca_key_pem" {
  value     = tls_private_key.root_ca_key.private_key_pem
  sensitive = true
}

output "wazuh_helm_release_name" {
  value       = module.wazuh_helm.release_name
  description = "The name of the deployed Wazuh Helm release."
}

output "wazuh_helm_namespace" {
  value       = module.wazuh_helm.namespace
  description = "The namespace where the Wazuh Helm release is deployed."
}