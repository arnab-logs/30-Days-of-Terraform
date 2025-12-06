# Environment
variable "environment" {
  default = "dev"
}

# Example instance sizes per environment
variable "instance_sizes" {
  default = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}

# String variable to manipulate
variable "mission_terraform" {
  default = "Mission is TERRAFORM"
}

# S3 bucket name needing formatting
variable "bucket_name" {
  default = "ProjectTerraform with CAPS and spaces!"
}

# Ports example as a string
variable "allowed_ports" {
  default = "80,443,8080,3306"
}

# Default and environment-specific tags
variable "default_tags" {
  default = {
    Team      = "DevOps"
    Project   = "TerraformPractice"
  }
}

variable "environment_tags" {
  default = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
