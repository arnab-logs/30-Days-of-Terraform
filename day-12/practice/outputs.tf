output "instance_type" {
  value = aws_instance.example.instance_type
}

output "backup_name" {
  value = var.backup_name
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}

output "unique_locations" {
  value = local.unique_locations
}

output "cost_summary" {
  value = {
    max     = local.max_cost
    min     = local.min_cost
    total   = local.total_cost
    average = local.average_cost
  }
}

output "config_data" {
  value = local.config_data
}
