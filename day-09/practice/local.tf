locals {
  common_tags = {
    Environment = var.environment
    Team        = "DevOps"
    ManagedBy   = "Terraform"
    Project     = "Day09-Lifecycle-Demo"
  }

  timestamp = formatdate("YYYY-MM-DD", timestamp())

  env_config = {
    dev = {
      instance_type = "t2.micro"
      multi_az      = false
    }
    staging = {
      instance_type = "t2.small"
      multi_az      = false
    }
    prod = {
      instance_type = "t2.medium"
      multi_az      = true
    }
  }

  current_env_config = lookup(local.env_config, var.environment, local.env_config["dev"])

  bucket_prefix = "${var.environment}-day09-lifecycle-demo"

  region_short = replace(data.aws_region.current.name, "-", "")

  az_count = length(data.aws_availability_zones.available.names)
}
