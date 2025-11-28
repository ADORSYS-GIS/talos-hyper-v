locals {
  longhorn_namespace = "longhorn-system"
}

resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = local.longhorn_namespace
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = local.longhorn_namespace
  create_namespace = false
  version          = var.longhorn_version

  set {
    name  = "service.ui.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.longhorn_system]
}

resource "kubernetes_manifest" "longhorn_filesystem_trim_daily" {
  provider = kubernetes

  manifest = {
    apiVersion = "longhorn.io/v1beta1"
    kind       = "RecurringJob"


    metadata = {
      name      = "filesystem-trim-job"
      namespace = local.longhorn_namespace
    }

    spec = {
      task = "filesystem-trim"

      # Use the user-defined Cron schedule variable
      cron = var.trim_cron_schedule

      concurrency = 1
      retain      = 0

      groups = var.longhorn_trim_groups
    }
  }

  depends_on = [helm_release.longhorn]
}

