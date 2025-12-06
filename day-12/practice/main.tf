# Simple EC2 instance example to use instance_type variable
resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type

  tags = {
    Name        = "example-instance"
    Environment = "Dev"
    BackupName  = var.backup_name
    Timestamp   = local.formatted_time
  }
}
