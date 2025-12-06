data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tags = merge(
    var.resource_tags,
    {
      Name = "Day09-Web-Server"
      Demo = "create_before_destroy"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "critical_data" {
  bucket = "day09-critical-data-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name     = "Day09 Critical Data Bucket"
      Demo     = "prevent_destroy"
      DataType = "Critical"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_launch_template" "app_server" {
  name_prefix   = "day09-app-server-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.resource_tags,
      {
        Name = "Day09 ASG Instance"
        Demo = "ignore_changes"
      }
    )
  }
}

resource "aws_autoscaling_group" "app_servers" {
  name               = "day09-app-asg"
  min_size           = 1
  max_size           = 5
  desired_capacity   = 2
  health_check_type  = "EC2"
  availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Day09 ASG Group"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_s3_bucket" "regional_validation" {
  bucket = "day09-region-validated-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name = "Day09 Region Validated Bucket"
      Demo = "precondition"
    }
  )

  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.name)
      error_message = "Region is NOT allowed for Day09 deployment!"
    }
  }
}

resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "day09-compliance-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name       = "Day09 Compliance Bucket"
      Demo       = "postcondition"
      Compliance = "SOC2"
    }
  )

  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "Compliance tag missing!"
    }
  }
}

resource "aws_security_group" "app_sg" {
  name        = "day09-app-security-group"
  description = "SG for Day09 app instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing"
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "Day09 App SG"
      Demo = "replace_triggered_by"
    }
  )
}

resource "aws_instance" "app_with_sg" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = merge(
    var.resource_tags,
    {
      Name = "Day09 App Instance"
      Demo = "replace_triggered_by"
    }
  )

  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg.id
    ]
  }
}

resource "aws_s3_bucket" "app_buckets" {
  for_each = var.bucket_names

  bucket = "${each.value}-${var.environment}-day09"

  tags = merge(
    var.resource_tags,
    {
      Name = each.value
      Demo = "for_each"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_dynamodb_table" "critical_app_data" {
  name         = "${var.environment}-day09-app-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "Day09 App Data"
      Demo = "multiple_rules"
    }
  )

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = contains(keys(var.resource_tags), "Environment")
      error_message = "Environment tag required!"
    }

    postcondition {
      condition     = self.billing_mode == "PAY_PER_REQUEST"
      error_message = "Only PAY_PER_REQUEST is allowed for Day09!"
    }
  }
}
