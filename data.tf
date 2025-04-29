data "aws_region" "current" {


}


data "aws_caller_identity" "current" {}

data "aws_availability_zones" "current" {
}


# Get the current AWS partition
data "aws_partition" "current" {}

# get elb service accounts for logging purposes
data "aws_elb_service_account" "current" {}

# Get latest Windows Server 2019 AMI
data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Uncomment to use KMS keys
data "aws_kms_key" "img_bldr_key" {
  key_id = "alias/image-builder"
}

data "aws_kms_key" "ebs_key" {
  key_id = "alias/ebs"
}