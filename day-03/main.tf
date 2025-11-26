terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

#Create an S3 bucket
resource "aws_s3_bucket" "day3_bucket" {
  bucket = "arnab-day3-terraform"

  tags = {
    Name        = "arnab day3 bucket"
    Environment = "Dev"
  }
}