# eks-cluster

Terraform for an EKS stack:
- EKS (module v21) + managed node group
- ECR
- CloudWatch control-plane logs (retention via `cloudwatch_retention_days`)
- AWS Secrets Manager + dedicated KMS key
- Argo CD via Helm (LoadBalancer service)
- (Optional) Amazon Managed Grafana (in ap-southeast-1)

## Usage
terraform init -upgrade
terraform validate
terraform apply

## Kubeconfig
aws eks update-kubeconfig --name pe-eks-cluster --region ap-south-1

## Argo CD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo
