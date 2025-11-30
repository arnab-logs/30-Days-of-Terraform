# Task 7 output
output "vpc_name" {
  value = var.tags["Name"]
}

# Task 10: Mixed Type Constraints
output "deployment_summary" {
  value = {
    environment    = var.environment
    instance_count = var.config.instance_count
    name_tag       = var.tags["Name"]
  }
}
