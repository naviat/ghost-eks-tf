variable "helm_config" {
  type        = any
  description = "Helm provider config for the aws_load_balancer_controller."
  default     = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "tags" {
  type        = map(string)
  description = "Common Tags for AWS resources"
}
