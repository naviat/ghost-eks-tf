terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}


data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-for-terraform.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-for-terraform.eks_cluster_id
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

locals {
  tenant      = "homelab"
  environment = "prod"
  zone        = "dev"

  kubernetes_version = "1.21"
  terraform_version  = "Terraform v1.0.1"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids  = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets
}


data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = var.tf_state_vpc_s3_bucket
    key    = var.tf_state_vpc_s3_key
    region = var.region
  }
}


#---------------------------------------------------------------
# Consume aws-eks-for-terraform module
#---------------------------------------------------------------
module "aws-eks-for-terraform" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

}

module "kubernetes-addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id        = module.aws-eks-for-terraform.eks_cluster_id
  eks_oidc_issuer_url   = module.aws-eks-for-terraform.eks_oidc_issuer_url
  eks_oidc_provider_arn = module.aws-eks-for-terraform.eks_oidc_provider_arn

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni = true # default is false
  #Optional
  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.10.1-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  enable_amazon_eks_coredns    = true # default is false
  #Optional
  amazon_eks_coredns_config = {
    addon_name               = "coredns"
    addon_version            = "v1.8.4-eksbuild.1"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }
  enable_amazon_eks_kube_proxy = true # default is false
  #Optional
  amazon_eks_kube_proxy_config = {
    addon_name               = "kube-proxy"
    addon_version            = "v1.21.2-eksbuild.2"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  ####
  #### ADDON FOR CLUSTER
  ####
  #---------------------------------------
  # CLUSTER AUTOSCALER HELM ADDON
  #---------------------------------------
  enable_cluster_autoscaler = true

  # Optional Map value
  cluster_autoscaler_helm_config = {
    name       = "cluster-autoscaler"                      # (Required) Release name.
    repository = "https://kubernetes.github.io/autoscaler" # (Optional) Repository URL where to locate the requested chart.
    chart      = "cluster-autoscaler"                      # (Required) Chart name to be installed.
    version    = "9.10.7"                                  # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "kube-system"                             # (Optional) The namespace to install the release into. Defaults to default
    timeout    = "1200"                                    # (Optional)
    lint       = "true"                                    # (Optional)

    values = [templatefile("${path.module}/helm_values/cluster-autoscaler-values.yaml", {
      operating_system = "linux"
    })]
  }
  #---------------------------------------
  # AWS LOAD BALANCER INGRESS CONTROLLER HELM ADDON
  #---------------------------------------
  enable_aws_load_balancer_controller = true
  # Optional
  aws_load_balancer_controller_helm_config = {
    name       = "aws-load-balancer-controller"
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    version    = "1.3.1"
    namespace  = "kube-system"
  }
  #---------------------------------------
  # METRICS SERVER HELM ADDON
  #---------------------------------------
  enable_metrics_server = true

  # Optional Map value
  metrics_server_helm_config = {
    name       = "metrics-server"                                    # (Required) Release name.
    repository = "https://kubernetes-sigs.github.io/metrics-server/" # (Optional) Repository URL where to locate the requested chart.
    chart      = "metrics-server"                                    # (Required) Chart name to be installed.
    version    = "3.5.0"                                             # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "kube-system"                                       # (Optional) The namespace to install the release into. Defaults to default
    timeout    = "1200"                                              # (Optional)
    lint       = "true"                                              # (Optional)

    values = [templatefile("${path.module}/helm_values/metrics-server-values.yaml", {
      operating_system = "linux"
    })]
  }
  #---------------------------------------
  # AWS-FOR-FLUENTBIT HELM ADDON
  #---------------------------------------
  enable_aws_for_fluentbit = true

  aws_for_fluentbit_helm_config = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${local.eks_cluster_id}/worker-fluentbit-logs" # Optional
    aws_for_fluentbit_cwlog_retention_in_days = 90
    create_namespace                          = true
    values = [templatefile("${path.module}/helm_values/aws-for-fluentbit-values.yaml", {
      region                          = data.aws_region.current.name,
      aws_for_fluent_bit_cw_log_group = "/${local.eks_cluster_id}/worker-fluentbit-logs"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
  #---------------------------------------
  # AWS NODE TERMINATION HANDLER HELM ADDON
  #---------------------------------------
  enable_aws_node_termination_handler = true
  # Optional
  aws_node_termination_handler_helm_config = {
    name       = "aws-node-termination-handler"
    chart      = "aws-node-termination-handler"
    repository = "https://aws.github.io/eks-charts"
    version    = "0.16.0"
    timeout    = "1200"
  }
  #---------------------------------------
  # COMMUNITY PROMETHEUS ENABLE
  #---------------------------------------
  # Amazon Prometheus Configuration to integrate with Prometheus Server Add-on
  enable_amazon_prometheus             = false
  amazon_prometheus_workspace_endpoint = module.aws-eks-for-terraform.amazon_prometheus_workspace_endpoint

  enable_prometheus = false
  # Optional Map value
  prometheus_helm_config = {
    name       = "prometheus"                                         # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "prometheus"                                         # (Required) Chart name to be installed.
    version    = "14.4.0"                                             # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "prometheus"                                         # (Optional) The namespace to install the release into. Defaults to default
    values = [templatefile("${path.module}/helm_values/prometheus-values.yaml", {
      operating_system = "linux"
    })]
  }
  #---------------------------------------
  # Vertical Pod Autoscaling
  #---------------------------------------
  enable_vpa = true

  vpa_helm_config = {
    name       = "vpa"                                 # (Required) Release name.
    repository = "https://charts.fairwinds.com/stable" # (Optional) Repository URL where to locate the requested chart.
    chart      = "vpa"                                 # (Required) Chart name to be installed.
    version    = "0.5.0"                               # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "vpa-ns"                              # (Optional) The namespace to install the release into. Defaults to default
    values     = [templatefile("${path.module}/helm_values/vpa-values.yaml", {})]
  }
  depends_on = [module.aws-eks-for-terraform.managed_node_groups]
}


# resource "kubernetes_secret" "some_secrets" {
  
#   "metadata": {
#     name = "some_secrets"
#   }

#   data {
#     s3_iam_access_secret = "${aws_iam_access_key.someresourcename.secret}"
#     rds_password = "${aws_db_instance.someresourcename.password}"
#   }
# }    