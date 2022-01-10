output "irsa_iam_role_arn" {
  description = "IAM role ARN for your service account"
  value       = aws_iam_role.irsa.arn
}

output "irsa_iam_role_name" {
  description = "IAM role name for your service account"
  value       = aws_iam_role.irsa.name
}
