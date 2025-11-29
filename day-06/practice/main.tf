#Create an S3 bucket
resource "aws_s3_bucket" "day_06_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
  }
}

#Create a VPC
resource "aws_vpc" "day_06_vpc" {
    cidr_block = "10.0.1.0/24"
    region = var.region
    tags = {
      Environment = var.environment
      Name        = local.vpc_name
    }
}

#Create an EC2 instance
resource "aws_instance" "day_06_ec2" {
    ami = "ami-0d176f79571d18a8f"
    instance_type = "t3.micro"
    region = var.region

    tags = {
      Environment = var.environment
      Name        = "${var.environment}-EC2-Instance"
    }
}