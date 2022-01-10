variable "kubernetes_namespace" {
  description = "Kubernetes Namespace name"
}

variable "create_kubernetes_namespace" {
  description = "Should the module create the namespace"
  type        = bool
  default     = true
}

variable "create_kubernetes_service_account" {
  description = "Should the module create the Service Account"
  type        = bool
  default     = true
}

variable "kubernetes_service_account" {
  description = "Kubernetes Service Account Name"
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster Id"
}

variable "iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM Role path"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for AWS resources"
  default     = null
}

variable "irsa_iam_policies" {
  type        = list(string)
  description = "IAM Policies for IRSA IAM role"
}
