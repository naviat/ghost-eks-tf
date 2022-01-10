variable "helm_config" {
  type        = any
  description = "Metrics server helm chart configuration"
  default     = {}
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}
