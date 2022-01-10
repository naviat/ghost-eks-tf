variable "helm_config" {
  type        = any
  default     = {}
  description = "ArgoCD Helm Chart Config values"
}

variable "argocd_applications" {
  type        = any
  default     = {}
  description = "ARGO CD Applications config to bootstrap the cluster"
}

variable "eks_cluster_id" {
  type        = string
  description = "Name for the EKS Cluster"
}

variable "add_on_config" {
  type        = any
  default     = {}
  description = "Configuration for managing add-ons via ArgoCD"
}
