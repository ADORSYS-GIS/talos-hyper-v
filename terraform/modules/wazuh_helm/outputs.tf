output "release_name" {
  value = helm_release.wazuh.name
  description = "The name of the deployed Wazuh Helm release."
}

output "namespace" {
  value = helm_release.wazuh.namespace
  description = "The namespace where the Wazuh Helm release is deployed."
}