variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "test"
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "enable_ebs_csi_driver" {
  description = "Whether to install AWS EBS CSI Driver"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "bitwarden_organization_id" {
  description = "Bitwarden organization ID"
  type        = string
  default     = null
}

variable "bitwarden_access_token" {
  description = "Bitwarden machine account access token (sensitive)"
  type        = string
  sensitive   = true
  default     = null
}

variable "bitwarden_secrets" {
  description = "Map of Bitwarden secrets to sync. Key is the secret name, value is the secret_id. Key name in Kubernetes secret will be auto-generated from the secret name."
  type        = map(string) # Map of secret_name -> secret_id
  default     = {}
}

# variable "enable_bitwarden_demo_app" {
#   description = "Enable k8s-inspector application (deployed via Helm chart)"
#   type        = bool
#   default     = false
# }

variable "k8s_inspector_chart_version" {
  description = "Version of the k8sinspector Helm chart"
  type        = string
  default     = null # Uses latest if not specified
}

variable "k8s_inspector_image_tag" {
  description = "Tag for the k8s-inspector container image"
  type        = string
  default     = "latest"
}

variable "k8s_inspector_replicas" {
  description = "Number of replicas for k8s-inspector"
  type        = number
  default     = 2
}

variable "enable_bitwarden_reader" {
  description = "Enable Bitwarden reader demo web app"
  type        = bool
  default     = false
}

variable "bitwarden_reader_secret_names" {
  description = "List of Kubernetes secret names to read and display in the reader app. If null, auto-generates from bitwarden_secrets modules."
  type        = list(string)
  default     = null # Changed to null so for_each expression in main.tf gets evaluated
}

variable "bitwarden_reader_ingress_enabled" {
  description = "Enable ALB ingress for Bitwarden reader app"
  type        = bool
  default     = true
}

variable "bitwarden_reader_ingress_scheme" {
  description = "ALB scheme for Bitwarden reader app (internet-facing or internal)"
  type        = string
  default     = "internet-facing"
}
