resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.eks_cluster_id
  addon_name               = local.add_on_config["addon_name"]
  addon_version            = local.add_on_config["addon_version"]
  resolve_conflicts        = local.add_on_config["resolve_conflicts"]
  service_account_role_arn = local.add_on_config["service_account_role_arn"] == "" ? module.irsa_addon.irsa_iam_role_arn : local.add_on_config["service_account_role_arn"]
  tags = merge(
    var.common_tags, local.add_on_config["tags"],
    { "eks_addon" = "vpc-cni" }
  )

  depends_on = [module.irsa_addon]
}

module "irsa_addon" {
  source                            = "../../../modules/irsa"
  eks_cluster_id                    = var.eks_cluster_id
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.add_on_config["namespace"]
  kubernetes_service_account        = local.add_on_config["service_account"]
  irsa_iam_policies                 = concat(["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"], local.add_on_config["additional_iam_policies"])
  tags                              = var.common_tags
}
