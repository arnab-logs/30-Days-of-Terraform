# EC2 Instance with Conditional Expression
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI
  instance_type = var.environment == "dev" ? "t2.micro" : "t3.micro"

  tags = merge(
    local.common_tags,
    { Name = "Example-${var.environment}" }
  )
}

# Security Group with Dynamic Blocks
resource "aws_security_group" "example_sg" {
  name        = "example-sg-${var.environment}"
  description = "Example SG using dynamic blocks"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  tags = local.common_tags
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = local.common_tags
}

# Subnets for Splat Expression demo
resource "aws_subnet" "example" {
  for_each = {
    public1  = "10.0.1.0/24"
    public2  = "10.0.2.0/24"
    private1 = "10.0.3.0/24"
  }

  cidr_block = each.value
  vpc_id     = aws_vpc.main.id
  tags       = merge(local.common_tags, { Name = each.key })
}
