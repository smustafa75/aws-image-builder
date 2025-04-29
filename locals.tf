locals {
  curr_region = data.aws_region.current.name

  common_tags = {
    Environment = "Production"
    Project     = "GoldenAMI"
    ManagedBy   = "Terraform"
    Owner       = "Infrastructure Team"
  }
}