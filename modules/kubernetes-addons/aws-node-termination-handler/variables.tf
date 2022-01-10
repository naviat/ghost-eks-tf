variable "helm_config" {
  description = "AWS Node Termination Handler Helm Chart Configuration"
  type        = any
  default     = {}
}

variable "autoscaling_group_names" {
  description = "EKS Node Group ASG names"
  type        = list(string)
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster Id"
}
