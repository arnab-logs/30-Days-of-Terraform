# Example S3 bucket using formatted bucket name
resource "aws_s3_bucket" "day11_bucket" {
  bucket = local.formatted_bucket_name
  tags   = local.merged_tags
}

# Example security group to demonstrate dynamic ports
resource "aws_security_group" "day11_sg" {
  name        = "day11-sg"
  description = "Security group for day 11 examples"

  dynamic "ingress" {
    for_each = local.sg_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  tags = local.merged_tags
}

# Example EC2 instance to show lookup function
resource "aws_instance" "day11_instance" {
  ami           = "ami-0c94855ba95c71c99" # Example Amazon Linux 2 AMI
  instance_type = local.instance_size
  tags          = local.merged_tags
}
