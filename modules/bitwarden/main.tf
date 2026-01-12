# Kubernetes namespace for operator
resource "kubernetes_namespace" "operator" {
  count = var.enable ? 1 : 0

  metadata {
    name = var.operator_namespace
    labels = merge(
      var.tags,
      {
        "app.kubernetes.io/name"       = "bitwarden-secrets-manager-operator"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    )
  }
}

# Kubernetes namespace for secrets
resource "kubernetes_namespace" "secrets" {
  count = var.enable ? 1 : 0

  metadata {
    name = var.namespace
    labels = merge(
      var.tags,
      {
        "app.kubernetes.io/name"       = "bitwarden-secrets"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    )
  }
}

# Kubernetes secret for Bitwarden access token
resource "kubernetes_secret" "auth_token" {
  count = var.enable && var.access_token != null ? 1 : 0

  metadata {
    name      = "bitwarden-auth-token"
    namespace = kubernetes_namespace.secrets[0].metadata[0].name
    labels = merge(
      var.tags,
      {
        "app.kubernetes.io/name"       = "bitwarden-auth-token"
        "app.kubernetes.io/managed-by" = "terraform"
      }
    )
  }

  # Store the raw token value - Kubernetes will base64-encode it automatically
  data = {
    token = var.access_token
  }

  type = "Opaque"
}

# Helm release for Bitwarden Secrets Manager Operator
resource "helm_release" "sm_operator" {
  count = var.enable ? 1 : 0

  name       = "sm-operator"
  repository = "https://charts.bitwarden.com/"
  chart      = "sm-operator"
  namespace  = kubernetes_namespace.operator[0].metadata[0].name
  version    = var.operator_helm_version

  create_namespace = false
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "settings.bwSecretsManagerRefreshInterval"
    value = var.bw_secrets_manager_refresh_interval
  }

  set {
    name  = "containers.manager.image.tag"
    value = var.manager_image_tag
  }

  depends_on = [
    kubernetes_namespace.operator[0]
  ]
}
