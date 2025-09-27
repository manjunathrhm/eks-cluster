variable "kubernetes_version" {
  default     = "1.30"
  description = "kubernetes version"
}
variable "workstation_cidr" {
  description = "Your public IP in CIDR form for EKS API access"
  type        = string
  # replace with YOUR public IP:
  default = "0.0.0.0/0"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}
variable "aws_region" {
  default     = "ap-south-1"
  description = "aws region"
}
variable "admin_principal_arns" {
  description = "IAM role/user ARNs to grant EKS cluster-admin via Access Entries"
  type        = list(string)
  default = [
    "arn:aws:iam::021685013567:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_9324f77486fe48d6"
  ]
}
# ---- Registry (ECR)
variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
  default     = "pe-eks-repo"
}

# ---- CloudWatch Logs
variable "cloudwatch_retention_days" {
  type        = number
  description = "Retention for CloudWatch log groups"
  default     = 30
}

# ---- Secrets Manager (Key Vault equivalent)
# You can set this via tfvars/CLI instead of committing secrets to code.
variable "example_secret_name" {
  type        = string
  description = "Path/name for an example secret in Secrets Manager"
  default     = "pe-eks/example" # change or add more secrets similarly
}
variable "example_secret_json" {
  type        = string
  description = "JSON string for the example secret (set via tfvars/CLI). Leave empty to skip creating a secret version."
  default     = "" # e.g. {"username":"demo","password":"changeme"}
  sensitive   = true
}

# ---- Managed Grafana
variable "enable_managed_grafana" {
  type        = bool
  description = "Create an Amazon Managed Grafana workspace"
  default     = true
}
variable "grafana_auth_providers" {
  type        = list(string)
  description = "Authentication providers for Grafana"
  default     = ["AWS_SSO"] # or ["SAML"]
}

# ---- Argo CD
variable "argocd_namespace" {
  type        = string
  description = "Namespace to install Argo CD"
  default     = "argocd"
}
variable "argocd_chart_version" {
  type        = string
  description = "Pin a Helm chart version for reproducible builds (leave empty for latest)"
  default     = "" # e.g. "7.6.12" for argo-cd chart
}

# ---- Tags (optional, if you don’t already have it)
variable "default_tags" {
  type        = map(string)
  description = "Common tags applied to resources"
  default = {
    ManagedBy = "terraform"
    Project   = "pe-eks"
  }
}

