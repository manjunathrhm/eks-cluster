output "cluster_endpoint" {
  value = data.aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "Push/pull URL for your images"
}

output "grafana_url" {
  value       = try(aws_grafana_workspace.this[0].endpoint, null)
  description = "Amazon Managed Grafana URL (null if disabled)"
}

output "argocd_namespace" {
  value       = kubernetes_namespace.argocd.metadata[0].name
  description = "Namespace where Argo CD is installed"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.example.arn
  description = "AWS Secrets Manager secret ARN"
}
