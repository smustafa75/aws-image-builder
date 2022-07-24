
## Backend
terraform {
  backend "s3" {
    profile = "PROFILE_NAME_FOR_PROGRAMATIC_ACCESS"
    bucket  = "S3_BUCKET"
    region  = "us-east-1"
    key     = "FILE_TO_STORE_STATE"
  }
}
