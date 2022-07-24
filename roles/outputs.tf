output "inst_prof_name" {
  value = aws_iam_instance_profile.golden-instance-profile.name
}
#output "inst_role_arn" {
#  value = aws_iam_instance_profile.golden-instance-profile.arn
#}

output "log_bucket" {
  value = aws_s3_bucket.image-builder-logs.arn
}

output "asset_bucket" {
  value = aws_s3_bucket.image-builder-bucket.id
}

output "log_bucket_imgbldr" {
  value = aws_s3_bucket.image-builder-logs.id
}