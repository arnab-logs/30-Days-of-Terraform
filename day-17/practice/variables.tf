variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Elastic Beanstalk application name"
  type        = string
  default     = "day-17-demo-my-app-bluegreen"
}

variable "solution_stack_name" {
  description = "EB solution stack"
  type        = string
  default     = "64bit Amazon Linux 2023 v6.6.8 running Node.js 20"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    Project     = "day-17-demo-BlueGreenDeployment"
    Environment = "day-17-demo"
    ManagedBy   = "Terraform"
    Owner       = "arnab"
  }
}
