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

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name = "day3-vpc"
  }
}

# Create an S3 bucket with dependency
resource "aws_s3_bucket" "day3_bucket" {
  bucket = "arnab-day3-terraform"

  tags = {
    Name        = "arnab day3 bucket"
    Environment = "Dev"
    VPC         = aws_vpc.main_vpc.id
  }
}
