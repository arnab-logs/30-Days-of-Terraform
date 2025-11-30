# Providerblock
provider "aws" {
  region = var.region
}

# Create an S3 bucket
resource "aws_s3_bucket" "day_05_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

# Create a VPC
resource "aws_vpc" "day_05_vpc" {
  cidr_block = "10.0.1.0/24"

  tags = {
    Environment = var.environment
    Name        = local.vpc_name
  }
}

# Create an EC2 instance
resource "aws_instance" "day_05_ec2" {
  ami           = "ami-0d176f79571d18a8f"
  instance_type = "t3.micro"

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-EC2-Instance"
  }
}

# Defining variables
variable "environment" {
  default = "dev"
}

variable "day_number" {
  default = "day-05"
}

variable "region" {
  default = "ap-south-1"
}

# Defining local variables
locals {
  bucket_name = "${var.day_number}-bucket-${var.environment}-${var.region}"
  vpc_name    = "${var.environment}-VPC"
}

# Defining output variables
output "vpc_id" {
  value = aws_vpc.day_05_vpc.id
}

output "ec2_id" {
  value = aws_instance.day_05_ec2.id
}
