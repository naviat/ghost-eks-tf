# ---------------------------------------------------------------------------------------------------------------------
# LABELING EKS RESOURCES
# ---------------------------------------------------------------------------------------------------------------------
module "eks_tags" {
  source      = "./modules/aws-resource-tags"
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = "eks"
  tags        = local.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CONTROL PLANE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kms_key" "eks" {
  description         = "EKS Cluster Secret Encryption Key"
  enable_key_rotation = true
}

module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.0.0"

  create_eks      = var.create_eks
  manage_aws_auth = false

  cluster_name    = module.eks_tags.id
  cluster_version = var.kubernetes_version

  # NETWORK CONFIG
  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  worker_create_security_group         = var.worker_create_security_group
  worker_additional_security_group_ids = var.worker_additional_security_group_ids
  cluster_log_retention_in_days        = var.cluster_log_retention_in_days

  # IRSA
  enable_irsa            = var.enable_irsa
  kubeconfig_output_path = "./kubeconfig/"

  # TAGS
  tags = module.eks_tags.tags

  # CLUSTER LOGGING
  cluster_enabled_log_types = var.cluster_enabled_log_types

  # CLUSTER ENCRYPTION
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Managed Prometheus Module
# ---------------------------------------------------------------------------------------------------------------------
module "aws_managed_prometheus" {
  count  = var.create_eks && var.enable_amazon_prometheus ? 1 : 0
  source = "./modules/aws-managed-prometheus"

  amazon_prometheus_workspace_alias = var.amazon_prometheus_workspace_alias
  eks_cluster_id                    = module.aws_eks.cluster_id
}

resource "kubernetes_config_map" "amazon_vpc_cni" {
  count = var.enable_windows_support ? 1 : 0
  metadata {
    name      = "amazon-vpc-cni"
    namespace = "kube-system"
  }

  data = {
    "enable-windows-ipam" = var.enable_windows_support ? "true" : "false"
  }

  depends_on = [
    module.aws_eks,
    data.http.eks_cluster_readiness[0]
  ]
}
