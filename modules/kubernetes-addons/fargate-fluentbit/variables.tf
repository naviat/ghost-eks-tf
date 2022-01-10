variable "eks_cluster_id" {
  type        = string
  description = "EKS cluster Id"
}

variable "addon_config" {
  type        = any
  description = "Fargate fluentbit configuration"
  default     = {}
}
