

module "networking" {
  source         = "./network"
  region_info    = data.aws_region.current.name
  account_id     = data.aws_caller_identity.current.account_id
  partition_info = data.aws_partition.current.partition
  s3_log_bucket  = module.inst_roles.log_bucket
  #tags   = var.tags
}

module "inst_roles" {
  source         = "./roles"
  region_info    = data.aws_region.current.name
  account_id     = data.aws_caller_identity.current.account_id
  partition_info = data.aws_partition.current.partition
}

module "imgbldr" {
  source         = "./imgbldr"
  region_info    = data.aws_region.current.name
  account_id     = data.aws_caller_identity.current.account_id
  partition_info = data.aws_partition.current.partition
  inst_profile   = module.inst_roles.inst_prof_name
  subnet_id      = module.networking.private_net
  p_subnet_id    = module.networking.public_net
  sec_grp        = module.networking.sg
  logging_bucket = module.inst_roles.log_bucket_imgbldr
  asset_bucket   = module.inst_roles.asset_bucket
  #  kms_key = data.aws_kms_key.img_bldr_key.arn
  #  kms_key_ebs = data.aws_kms_key.ebs_key.arn
  #tags   = var.tags
}