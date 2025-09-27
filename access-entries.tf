########################################
# EKS Access Entries (cluster-admin)
########################################

# Create an Access Entry for each principal
resource "aws_eks_access_entry" "admin" {
  for_each      = toset(var.admin_principal_arns)
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value
  type          = "STANDARD"
  depends_on    = [module.eks]
}

# Attach the cluster-admin policy after the entry exists
resource "aws_eks_access_policy_association" "admin" {
  for_each      = aws_eks_access_entry.admin
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }
}