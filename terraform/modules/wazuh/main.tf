resource "kubernetes_namespace" "wazuh" {
  metadata {
    name = "wazuh"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }

}

# --- Root CA key ---
resource "tls_private_key" "root_ca_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- Self-signed Root CA cert ---
resource "tls_self_signed_cert" "root_ca" {
  private_key_pem       = tls_private_key.root_ca_key.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 3650 * 24 # ~10 years

  subject {
    country      = var.subject.country
    locality     = var.subject.locality
    organization = var.subject.organization
    common_name  = var.subject.common_name
  }

  # Conservative, CA-appropriate usages
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
    "key_encipherment",
  ]

  # Keep it SHA-256 like your openssl command
  early_renewal_hours = 0
}

# --- (Optional) Write files to disk (mirrors your OUTPUT_FOLDER) ---
resource "local_file" "root_ca_pem" {
  content  = tls_self_signed_cert.root_ca.cert_pem
  filename = "${var.output_folder}/root-ca.pem"
}

resource "local_file" "root_ca_key_pem" {
  content         = tls_private_key.root_ca_key.private_key_pem
  filename        = "${var.output_folder}/root-ca-key.pem"
  file_permission = "0600"
}

# --- Kubernetes Secret with the PEMs ---
resource "kubernetes_secret" "wazuh_root_ca" {
  metadata {
    name      = var.root_secret_name
    namespace = kubernetes_namespace.wazuh.metadata[0].name
  }

  type = "Opaque"

  data = {
    "root-ca.pem"     = tls_self_signed_cert.root_ca.cert_pem
    "root-ca-key.pem" = tls_private_key.root_ca_key.private_key_pem
  }

  depends_on = [
    kubernetes_namespace.wazuh
  ]
}

module "wazuh_helm" {
  source                     = "../wazuh_helm"
  release_name               = var.wazuh_helm_config.helm_release_name
  chart_version              = var.wazuh_helm_config.helm_chart_version
  namespace                  = kubernetes_namespace.wazuh.metadata[0].name
  root_secret_name           = var.root_secret_name
  master_enrollment_password = var.wazuh_helm_config.master_enrollment_password
  indexer_auth_username      = var.wazuh_helm_config.indexer_auth_username
  indexer_auth_password      = var.wazuh_helm_config.indexer_auth_password

  depends_on = [kubernetes_secret.wazuh_root_ca]
}
