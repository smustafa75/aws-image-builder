data "aws_region" "current" {


}


data "aws_caller_identity" "current" {}

data "aws_availability_zones" "current" {
}


# Get the current AWS partition
data "aws_partition" "current" {}

# get elb service accounts for logging purposes
data "aws_elb_service_account" "current" {}

#data "aws_kms_key" "img_bldr_key" {

#key_id = "alias/image-builder"
#}

#data "aws_kms_key" "ebs_key" {
#key_id = "alias/ebs"
#}