output "ec2_instance_id" {
  description = "The ID of the EC2 instance created"
  value       = aws_instance.demo_instance.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.demo_instance.public_ip
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.demo_instance.private_ip
}
