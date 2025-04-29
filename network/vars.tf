
variable "region_info" {
  description = "AWS Region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "partition_info" {
  description = "AWS Partition"
  type        = string
}

variable "s3_log_bucket" {
  description = "S3 bucket for logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}