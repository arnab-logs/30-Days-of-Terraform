# Data Source: Existing VPC
data "aws_vpc" "vpc_name" {
  filter {
    name   = "tag:Name"
    values = ["day-13-vpc"]
  }
}

# Data Source: Existing Subnet
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["day-13-subnet"]
  }
  vpc_id = data.aws_vpc.vpc_name.id
}

# Data Source: Latest Amazon Linux 2 AMI
data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance using Data Sources
resource "aws_instance" "demo_instance" {
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.shared.id
  tags          = var.tags
}
