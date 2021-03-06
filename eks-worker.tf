# ---------------------------------------------------------------------------------------------------------------------
# MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "aws_eks_managed_node_groups" {
  source = "./modules/aws-eks-managed-node-groups"

  for_each = { for key, value in var.managed_node_groups : key => value
    if length(var.managed_node_groups) > 0
  }

  managed_ng = each.value

  eks_cluster_id    = module.aws_eks.cluster_id
  cluster_ca_base64 = module.aws_eks.cluster_certificate_authority_data
  cluster_endpoint  = module.aws_eks.cluster_endpoint

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  worker_security_group_id          = module.aws_eks.worker_security_group_id
  cluster_security_group_id         = module.aws_eks.cluster_security_group_id
  cluster_primary_security_group_id = module.aws_eks.cluster_primary_security_group_id
  tags                              = module.eks_tags.tags

  depends_on = [module.aws_eks, kubernetes_config_map.aws_auth]

}

# ---------------------------------------------------------------------------------------------------------------------
# SELF MANAGED NODE GROUPS - WILL UPDATE LATER
# ---------------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------------
# FARGATE PROFILES - UPDATE LATER
# ---------------------------------------------------------------------------------------------------------------------
