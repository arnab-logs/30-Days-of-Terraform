output "web_server_id" {
  description = "Day09 web server ID"
  value       = aws_instance.web_server.id
}

output "critical_bucket_name" {
  description = "Day09 critical S3 bucket"
  value       = aws_s3_bucket.critical_data.id
}

output "asg_name" {
  description = "Day09 ASG name"
  value       = aws_autoscaling_group.app_servers.name
}

output "app_bucket_names" {
  description = "Day09 application buckets"
  value       = [for b in aws_s3_bucket.app_buckets : b.id]
}

output "dynamodb_table_name" {
  description = "Day09 DynamoDB table"
  value       = aws_dynamodb_table.critical_app_data.name
}
