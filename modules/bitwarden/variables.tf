variable "enable" {
  description = "Enable/disable the Bitwarden Secrets Manager module"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for Bitwarden secrets"
  type        = string
  default     = "bitwarden-secrets"
}

variable "operator_namespace" {
  description = "Namespace for the Bitwarden Secrets Manager Operator"
  type        = string
  default     = "sm-operator-system"
}

variable "organization_id" {
  description = "Bitwarden organization ID"
  type        = string
  default     = null
}

variable "access_token" {
  description = "Bitwarden machine account access token (sensitive)"
  type        = string
  sensitive   = true
  default     = null
}

variable "operator_helm_version" {
  description = "Version of the Bitwarden Secrets Manager Operator Helm chart"
  type        = string
  default     = null
}

variable "bw_secrets_manager_refresh_interval" {
  description = "Refresh interval for Bitwarden Secrets Manager in seconds. Minimum value is 180. Default is 300 (5 minutes)."
  type        = number
  default     = 300
}

variable "manager_image_tag" {
  description = "Tag for the Bitwarden Secrets Manager Operator manager container image. If empty string (default), will use the Chart's AppVersion. Set to override with a specific image tag."
  type        = string
  default     = ""
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_data" {
  description = "EKS cluster CA certificate data"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
