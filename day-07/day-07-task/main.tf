# Task 1: String Constraint
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "example" {
  bucket = "${var.environment}-my-app-bucket"
}

# Task 2: Number Constraint
resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = "ami-0d176f79571d18a8f" # Example AMI
  instance_type = "t2.micro"
}

# Task 3: Boolean Constraint
resource "aws_instance" "app_monitoring" {
  ami                        = "ami-0d176f79571d18a8f"
  instance_type              = "t2.micro"
  monitoring                 = var.monitoring_enabled
  associate_public_ip_address = var.associate_public_ip
}

# Task 4: List(string) Constraint (CIDR blocks)
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block[0]
  tags       = var.tags
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block[1]
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block[2]
}

# Task 5: List(string) Constraint (allowed VM types)
resource "aws_instance" "validated_instance" {
  ami           = "ami-0d176f79571d18a8f"
  instance_type = "t2.micro"

  lifecycle {
    precondition {
      condition     = contains(var.allowed_vm_types, "t2.micro")
      error_message = "Selected instance type not allowed!"
    }
  }
}

# Task 6: Set(string) Constraint (allowed region validation)
locals {
  is_region_allowed = contains(var.allowed_region, var.region)
}

resource "aws_s3_bucket" "validate_region" {
  bucket = "region-check-bucket"
  count  = local.is_region_allowed ? 1 : 0
}

# Task 7: Map(string) Constraint (tags)
resource "aws_vpc" "vpc_with_tags" {
  cidr_block = "10.1.0.0/16"
  tags       = var.tags
}

# Task 8: Tuple Constraint (ingress values)
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow inbound traffic"

  ingress {
    from_port   = var.ingress_values[0]
    protocol    = var.ingress_values[1]
    to_port     = var.ingress_values[2]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Task 9: Object Constraint (config)
provider "aws" {
  region = var.config.region
}

resource "aws_instance" "config_instance" {
  count         = var.config.instance_count
  ami           = "ami-0d176f79571d18a8f"
  instance_type = "t2.micro"
  monitoring    = var.config.monitoring
}
