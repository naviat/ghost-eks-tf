# Assume role policy for your service account
data "aws_iam_policy_document" "irsa_with_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"]
    }
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_id
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}
