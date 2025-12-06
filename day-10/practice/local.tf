locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Day-10-Terraform-Expressions"
    Team        = "DevOps"
  }
}
