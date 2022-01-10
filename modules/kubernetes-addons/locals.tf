
locals {
  # Configuration for managing add-ons via ArgoCD.
  argocd_add_on_config = {
    awsForFluentBit           = var.enable_aws_for_fluentbit ? module.aws_for_fluent_bit[0].argocd_gitops_config : null
    awsLoadBalancerController = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller[0].argocd_gitops_config : null
    certManager               = var.enable_cert_manager ? module.cert_manager[0].argocd_gitops_config : null
    clusterAutoscaler         = var.enable_cluster_autoscaler ? module.cluster_autoscaler[0].argocd_gitops_config : null
    ingressNginx              = var.enable_ingress_nginx ? module.ingress_nginx[0].argocd_gitops_config : null
    metricsServer             = var.enable_metrics_server ? module.metrics_server[0].argocd_gitops_config : null
    prometheus                = var.enable_prometheus ? module.prometheus[0].argocd_gitops_config : null
  }
}
