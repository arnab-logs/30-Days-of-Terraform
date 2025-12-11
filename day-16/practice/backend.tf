terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-arnab"
    key    = "day-16-demo/terraform.tfstate"
    region = "us-east-1"
  }
}
