terraform {
  required_version = "1.7.5"

  # store tfstate file into the bucket
  backend "s3" {
    bucket = "terraform-state-bucket-2024-mk"
    key = "terraform.state"
    region = "ap-northeast-1"
  }
}
