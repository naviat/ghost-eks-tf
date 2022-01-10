output "cw_log_group_name" {
  description = "AWS Fluent Bit CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.eks_worker_logs.name
}

output "cw_log_group_arn" {
  description = "AWS Fluent Bit CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.eks_worker_logs.arn
}

output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
