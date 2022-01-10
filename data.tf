data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.aws_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.aws_eks.cluster_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "eks_cluster_readiness" {
  count = var.create_eks ? 1 : 0

  url            = join("/", [data.aws_eks_cluster.cluster.0.endpoint, "healthz"])
  ca_certificate = base64decode(data.aws_eks_cluster.cluster.0.certificate_authority.0.data)
  timeout        = 300
}
