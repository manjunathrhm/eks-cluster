module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                                     = "pe-eks-cluster"
  kubernetes_version                       = var.kubernetes_version
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  endpoint_public_access                   = true
  endpoint_private_access                  = true
  endpoint_public_access_cidrs             = ["0.0.0.0/0"]
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = false
  enabled_log_types                        = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group              = true
  cloudwatch_log_group_retention_in_days   = var.cloudwatch_retention_days

  # Core add-ons
  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
  }

  # One managed node group
  eks_managed_node_groups = {
    node_group = {
      ami_type       = "AL2023_x86_64_STANDARD" # valid value
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1



      # If you have a custom worker SG, uncomment:
      # additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

      tags = { cluster = "demo" }
    }
  }

  # Module-level tags
  tags = { cluster = "demo" }
}
# Cluster info for providers
data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }

  tags = var.default_tags
}

resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager (${module.eks.cluster_name})"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = var.default_tags
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${module.eks.cluster_name}-secrets"
  target_key_id = aws_kms_key.secrets.id
}

resource "aws_secretsmanager_secret" "example" {
  name       = var.example_secret_name
  kms_key_id = aws_kms_key.secrets.arn
  tags       = var.default_tags
}

resource "aws_secretsmanager_secret_version" "example" {
  count         = length(trimspace(var.example_secret_json)) == 0 ? 0 : 1
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = var.example_secret_json
}
resource "aws_grafana_workspace" "this" {
  provider                 = aws.amg
  count                    = var.enable_managed_grafana ? 1 : 0
  name                     = "${module.eks.cluster_name}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = var.grafana_auth_providers
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH", "PROMETHEUS"]
  tags                     = var.default_tags
}

resource "kubernetes_namespace" "argocd" {
  provider = kubernetes.eks
  metadata { name = var.argocd_namespace }
  depends_on = [module.eks]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Pin if you want reproducible installs:
  # version = var.argocd_chart_version != "" ? var.argocd_chart_version : null

  values = [
    yamlencode({
      server = { service = { type = "LoadBalancer" } }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

