# Bitwarden Reader Module

A Terraform module that deploys the [bitwarden-reader Helm chart](https://k8sforge.github.io/bitwarden-reader-chart/) to demonstrate reading secrets synced from Bitwarden Secrets Manager to Kubernetes.

## Overview

This module uses the [bitwarden-reader Helm chart](https://k8sforge.github.io/bitwarden-reader-chart/) to deploy a web application that:

- Reads Kubernetes secrets synced by the Bitwarden Secrets Manager Operator
- Displays secrets in a user-friendly web interface
- Shows sync status and metadata from BitwardenSecret CRDs
- Provides REST API endpoints for programmatic access

**Helm Chart**: [bitwarden-reader](https://k8sforge.github.io/bitwarden-reader-chart/)
**Container Image**: `ghcr.io/platformfuzz/k8s-bitwarden-reader:latest`

## Features

- **Helm Chart**: Uses the official bitwarden-reader Helm chart
- **Web UI**: Beautiful, responsive interface to view synced secrets
- **API Endpoints**: REST API for programmatic access
- **RBAC**: Proper Kubernetes RBAC for reading secrets and BitwardenSecret CRDs
- **Health Checks**: Liveness and readiness probes
- **ALB Ingress**: Optional public ALB for external access

## Usage

```hcl
module "bitwarden_reader" {
  source = "./modules/bitwarden-reader"

  namespace        = "bitwarden-secrets"
  create_namespace = false
  secret_names     = ["example-secret", "example-secret2"]

  # Optional: Chart version (defaults to latest)
  chart_version = "0.1.0"

  ingress_enabled = true
  ingress_scheme  = "internet-facing"

  tags = local.common_tags
}
```

**Note**: The `cluster_endpoint`, `cluster_ca_data`, and `cluster_name` variables are no longer required as Helm uses the Kubernetes provider's configuration directly.

## Architecture

```
Bitwarden Secrets Manager
         ↓
Bitwarden Operator (syncs)
         ↓
Kubernetes Secret (example-secret)
         ↓
Bitwarden Reader App (reads & displays)
```

## Endpoints

- `/` - Main web interface
- `/api/v1/secrets` - JSON API for secrets
- `/api/v1/health` - Health check endpoint

## Requirements

- Bitwarden Secrets Manager Operator installed
- BitwardenSecret CRD configured
- Secrets synced to the target namespace
- RBAC permissions to read secrets

## Variables

See `variables.tf` for all available configuration options.

## Outputs

- `app_url` - URL to access the application
- `alb_hostname` - ALB hostname (if ingress enabled)
- `namespace` - Namespace where app is deployed
- `service_name` - Kubernetes service name
