output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = var.create_eks ? split("//", module.aws_eks.cluster_oidc_issuer_url)[1] : "EKS Cluster not enabled"
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.create_eks ? module.aws_eks.oidc_provider_arn : "EKS Cluster not enabled"
}

output "eks_cluster_id" {
  description = "Kubernetes Cluster Name"
  value       = var.create_eks ? module.aws_eks.cluster_id : "EKS Cluster not enabled"
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = var.create_eks ? "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${module.aws_eks.cluster_id}" : "EKS Cluster not enabled"
}

output "cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = module.aws_eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "EKS Cluster Security group ID"
  value       = module.aws_eks.cluster_primary_security_group_id
}

output "worker_security_group_id" {
  description = "EKS Worker Security group ID created by EKS module"
  value       = module.aws_eks.worker_security_group_id
}

output "managed_node_group_iam_role_arns" {
  description = "IAM role arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
}


output "managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? module.aws_eks_managed_node_groups.* : []
}


output "managed_node_group_aws_auth_config_map" {
  description = "Managed node groups AWS auth map"
  value       = local.managed_node_group_aws_auth_config_map.*
}


output "amazon_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  value       = var.create_eks && var.enable_amazon_prometheus ? module.aws_managed_prometheus[0].amazon_prometheus_workspace_endpoint : null
}
