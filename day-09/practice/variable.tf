variable "aws_region" {
  description = "AWS region for Day09 lifecycle examples"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment for Day09 demo (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "bucket_names" {
  description = "Bucket names used in Day09 lifecycle examples"
  type        = set(string)
  default     = ["day09-demo-bucket-001", "day09-demo-bucket-002"]
}

variable "allowed_regions" {
  description = "Allowed regions for Day09 lifecycle precondition"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1", "ap-south-1"]
}

variable "instance_type" {
  description = "EC2 instance type for Day09"
  type        = string
  default     = "t3.micro"
}

variable "resource_tags" {
  description = "Common tags for all Day09 resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "DevOps"
    CostCenter  = "Engineering"
  }
}
