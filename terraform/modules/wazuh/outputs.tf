output "root_ca_pem" {
  value     = tls_self_signed_cert.root_ca.cert_pem
  sensitive = true
}

output "root_ca_key_pem" {
  value     = tls_private_key.root_ca_key.private_key_pem
  sensitive = true
}