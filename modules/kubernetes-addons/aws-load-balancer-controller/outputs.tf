output "ingress_namespace" {
  value = local.helm_config["namespace"]
}

output "ingress_name" {
  value = local.helm_config["name"]
}

output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
