variable "region" {
  type        = string
  description = "AWS region"
}

variable "tf_state_vpc_s3_bucket" {
  type        = string
  description = "Terraform state S3 Bucket Name"
}

variable "tf_state_vpc_s3_key" {
  type        = string
  description = "Terraform state S3 Key path"
}
