variable "aws_region" {
  description = "AWS region to deploy Day-14 demo resources."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_prefix" {
  description = "Prefix for the Day-14 Demo S3 bucket."
  type        = string
  default     = "day-14-demo-website-"
}
