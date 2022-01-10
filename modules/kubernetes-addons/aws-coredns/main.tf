resource "aws_eks_addon" "coredns" {
  cluster_name             = var.eks_cluster_id
  addon_name               = local.add_on_config["addon_name"]
  addon_version            = local.add_on_config["addon_version"]
  resolve_conflicts        = local.add_on_config["resolve_conflicts"]
  service_account_role_arn = local.add_on_config["service_account_role_arn"]
  tags = merge(
    var.common_tags, local.add_on_config["tags"],
    { "eks_addon" = "coredns" }
  )

}
