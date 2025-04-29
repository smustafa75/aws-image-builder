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

variable "inst_profile" {
  description = "Instance Profile for Image Builder"
  type        = string
}

variable "subnet_id" {
  description = "Private Subnet ID for Image Builder"
  type        = string
  default     = ""
}

variable "p_subnet_id" {
  description = "Public Subnet ID for Image Builder"
  type        = string
  default     = ""
}

variable "sec_grp" {
  description = "Security Group IDs for Image Builder"
  type        = list(string)
  default     = []
}

variable "logging_bucket" {
  description = "S3 Bucket for Image Builder Logs"
  type        = string
}

variable "asset_bucket" {
  description = "S3 Bucket for Image Builder Assets"
  type        = string
}

variable "kms_key" {
  description = "KMS Key ARN for Image Builder"
  type        = string
  default     = null
}

variable "kms_key_ebs" {
  description = "KMS Key ARN for EBS Volumes"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Project     = "GoldenAMI"
    ManagedBy   = "Terraform"
  }
}