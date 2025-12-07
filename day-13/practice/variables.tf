variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Team        = "DevOps"
    ManagedBy   = "Terraform"
    Project     = "Day-13-Demo"
  }
}
