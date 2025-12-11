# Get AWS Account ID
data "aws_caller_identity" "current" {}

output "day-16-demo-account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Read users from CSV
locals {
  day_16_demo_users = csvdecode(file("day-16-demo-users.csv"))
}

output "day-16-demo-user-names" {
  value = [
    for user in local.day_16_demo_users :
    "${user.first_name} ${user.last_name}"
  ]
}

# Create IAM Users Automatically
resource "aws_iam_user" "day_16_demo_users" {
  for_each = {
    for user in local.day_16_demo_users :
    user.first_name => user
  }

  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  path = "/day-16-demo/users/"

  tags = {
    DisplayName = "${each.value.first_name} ${each.value.last_name}"
    Department  = each.value.department
    Role        = each.value.job_title
    Project     = "day-16-demo"
  }
}

# Create IAM Login Profiles
resource "aws_iam_user_login_profile" "day_16_demo_profile" {
  for_each = aws_iam_user.day_16_demo_users

  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
    ]
  }
}

output "day-16-demo-user-passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.day_16_demo_profile :
    user => "Password generated – must reset on first login"
  }
  sensitive = true
}
