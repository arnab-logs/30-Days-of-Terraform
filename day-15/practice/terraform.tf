terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-arnab"
    key    = "lessons/day15/day-15-demo-terraform.tfstate"
    region = "us-east-1"
  }
}
