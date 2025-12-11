resource "helm_release" "wazuh" {
  name       = var.release_name
  repository = "https://adorsys-gis.github.io/wazuh-helm/"
  chart      = "wazuh-helm"
  version    = var.chart_version
  namespace  = var.namespace
  timeout    = 600

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      lb_ips                     = var.helm_values_load_balancer_ips,
      jira_webhook_url           = var.helm_values_jira_webhook_url,
      teams_webhook_url          = var.helm_values_teams_webhook_url,
      root_ca_secret_name        = var.root_secret_name,
      master_enrollment_password = var.master_enrollment_password,
      dashboard_branding = {
        logo_default_url         = var.helm_values_dashboard_branding_logo_default_url,
        mark_default_url         = var.helm_values_dashboard_branding_mark_default_url,
        loading_logo_default_url = var.helm_values_dashboard_branding_loading_logo_default_url,
        favicon_url              = var.helm_values_dashboard_branding_favicon_url,
        application_title        = var.helm_values_dashboard_branding_application_title
      }
    }),
    file("${path.module}/templates/values-longhorn.yaml"),
    file("${path.module}/templates/values-permission.fix.yaml"),
  ]
}
