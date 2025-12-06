# Output instance ID (Conditional Expression demo)
output "instance_id" {
  value = aws_instance.example.id
}

# Output all subnet IDs using Splat Expression
output "all_subnet_ids" {
  value = aws_subnet.example[*].id
}

# Output Security Group ID
output "security_group_id" {
  value = aws_security_group.example_sg.id
}
