#-----------------AWS Managed EKS Add-ons----------------------

module "aws_vpc_cni" {
  count          = var.enable_amazon_eks_vpc_cni ? 1 : 0
  source         = "./aws-vpc-cni"
  add_on_config  = var.amazon_eks_vpc_cni_config
  eks_cluster_id = var.eks_cluster_id
  common_tags    = var.tags
}

module "aws_coredns" {
  count          = var.enable_amazon_eks_coredns ? 1 : 0
  source         = "./aws-coredns"
  add_on_config  = var.amazon_eks_coredns_config
  eks_cluster_id = var.eks_cluster_id
  common_tags    = var.tags
}

module "aws_kube_proxy" {
  count          = var.enable_amazon_eks_kube_proxy ? 1 : 0
  source         = "./aws-kube-proxy"
  add_on_config  = var.amazon_eks_kube_proxy_config
  eks_cluster_id = var.eks_cluster_id
  common_tags    = var.tags
}

#-----------------Kubernetes Add-ons----------------------
module "argocd" {
  count               = var.enable_argocd ? 1 : 0
  source              = "./argocd"
  helm_config         = var.argocd_helm_config
  argocd_applications = var.argocd_applications
  eks_cluster_id      = var.eks_cluster_id
  add_on_config       = local.argocd_add_on_config
}

module "aws_for_fluent_bit" {
  count             = var.enable_aws_for_fluentbit ? 1 : 0
  source            = "./aws-for-fluentbit"
  helm_config       = var.aws_for_fluentbit_helm_config
  eks_cluster_id    = var.eks_cluster_id
  manage_via_gitops = var.argocd_manage_add_ons
}

module "aws_load_balancer_controller" {
  count                 = var.enable_aws_load_balancer_controller ? 1 : 0
  source                = "./aws-load-balancer-controller"
  helm_config           = var.aws_load_balancer_controller_helm_config
  eks_cluster_id        = var.eks_cluster_id
  eks_oidc_issuer_url   = var.eks_oidc_issuer_url
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  tags                  = var.tags
  manage_via_gitops     = var.argocd_manage_add_ons
}

module "aws_node_termination_handler" {
  count  = var.enable_aws_node_termination_handler && length(var.auto_scaling_group_names) > 0 ? 1 : 0
  source = "./aws-node-termination-handler"

  eks_cluster_id          = var.eks_cluster_id
  helm_config             = var.aws_node_termination_handler_helm_config
  autoscaling_group_names = var.auto_scaling_group_names
}

module "cert_manager" {
  count             = var.enable_cert_manager ? 1 : 0
  source            = "./cert-manager"
  helm_config       = var.cert_manager_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "cluster_autoscaler" {
  count             = var.enable_cluster_autoscaler ? 1 : 0
  source            = "./cluster-autoscaler"
  helm_config       = var.cluster_autoscaler_helm_config
  eks_cluster_id    = var.eks_cluster_id
  manage_via_gitops = var.argocd_manage_add_ons
}

module "ingress_nginx" {
  count             = var.enable_ingress_nginx ? 1 : 0
  source            = "./ingress-nginx"
  helm_config       = var.ingress_nginx_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "metrics_server" {
  count             = var.enable_metrics_server ? 1 : 0
  source            = "./metrics-server"
  helm_config       = var.metrics_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
}

module "prometheus" {
  count          = var.enable_prometheus ? 1 : 0
  source         = "./prometheus"
  eks_cluster_id = var.eks_cluster_id
  helm_config    = var.prometheus_helm_config
  #AWS Managed Prometheus Workspace
  enable_amazon_prometheus             = var.enable_amazon_prometheus
  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  manage_via_gitops                    = var.argocd_manage_add_ons
  tags                                 = var.tags
}

module "vpa" {
  count       = var.enable_vpa ? 1 : 0
  source      = "./vpa"
  helm_config = var.vpa_helm_config
}
