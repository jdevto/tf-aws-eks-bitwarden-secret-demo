variable "namespace" {
  description = "Namespace for the reader demo app"
  type        = string
  default     = "bitwarden-secrets"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = false
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "bitwarden-reader"
}

variable "image" {
  description = "Container image for the reader app"
  type        = string
  default     = "ghcr.io/platformfuzz/k8s-bitwarden-reader:latest"
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
  default     = "IfNotPresent"
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "secret_names" {
  description = "List of Kubernetes secret names to read and display"
  type        = list(string)
  default     = ["example-secret"]
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

variable "ingress_enabled" {
  description = "Enable ALB ingress"
  type        = bool
  default     = true
}

variable "ingress_scheme" {
  description = "ALB scheme (internet-facing or internal)"
  type        = string
  default     = "internet-facing"
}

variable "chart_version" {
  description = "Version of the bitwarden-reader Helm chart (leave empty for latest)"
  type        = string
  default     = ""
}
