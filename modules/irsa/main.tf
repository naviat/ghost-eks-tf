resource "kubernetes_namespace_v1" "irsa" {
  count = var.create_kubernetes_namespace ? 1 : 0
  metadata {
    name = var.kubernetes_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "aws-eks-for-terraform"
    }
  }
}

resource "kubernetes_service_account_v1" "irsa" {
  count = var.create_kubernetes_service_account ? 1 : 0
  metadata {
    name        = var.kubernetes_service_account
    namespace   = var.kubernetes_namespace
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.irsa.arn }
    labels = {
      "app.kubernetes.io/managed-by" = "aws-eks-for-terraform"
    }
  }

  automount_service_account_token = true
}

resource "aws_iam_role" "irsa" {
  name                  = "${var.eks_cluster_id}-${var.kubernetes_service_account}-irsa"
  assume_role_policy    = join("", data.aws_iam_policy_document.irsa_with_oidc.*.json)
  path                  = var.iam_role_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count      = length(var.irsa_iam_policies)
  policy_arn = var.irsa_iam_policies[count.index]
  role       = aws_iam_role.irsa.name
}
