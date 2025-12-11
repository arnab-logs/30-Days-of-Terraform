
# Day 16 — Bulk IAM User Management With Terraform

Hello and welcome back!

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-41-day-16-aws-terraform-iam-authentication)

Yesterday, we wrapped up a meaningful mini-project on AWS VPC Peering using Terraform. A topic that can feel intimidating at first, but we walked through it step by step, making everything approachable and clear.

Today, we’re easing into Day 16 of the 30 Days of AWS Terraform journey, and we’re answering an important question every cloud beginner eventually has:

How do we manage users in AWS, especially when there are dozens of them?

Terraform makes this entire process beautifully automated.

---

## What We Will Cover Today

- Preparing a CSV file containing all our user details  
- Converting that CSV into a Terraform-friendly structure  
- Creating IAM users dynamically  
- Assigning users to IAM groups based on department  
- Creating login profiles so users can log into the AWS console  
- Everything explained slowly, warmly, and beginner-friendly  

# 1. Creating the CSV File — Laying the Foundation

Before writing any Terraform code, we start with something simple: a CSV file.  
This tiny file becomes the backbone of our entire mini-project.

Our CSV will contain four fields:

first_name
last_name
department
job_title

Example:

```csv
first_name,last_name,department,job_title
John,Doe,Education,Trainer
Sara,Lee,Engineering,Developer
Mark,Stone,Managers,Team Lead
```
Save the file as users.csv in your Terraform folder.

# 2. Converting the CSV Into Terraform Data — Understanding csvdecode()
Terraform sees the CSV as raw text, so we convert it into structured data using csvdecode().

```hcl
locals {
  users = csvdecode(file("users.csv"))
}
```
Each row becomes a map:

```hcl
{
  first_name = "John"
  last_name  = "Doe"
  department = "Education"
  job_title  = "Trainer"
}
```
Now Terraform can loop through users, extract fields, and create IAM resources dynamically.

# 3. Retrieving the AWS Account ID — Using a Data Source
Terraform needs to know which AWS account it is working in.
We fetch this using:

``` hcl
data "aws_caller_identity" "current" {}
```
We primarily use:

```kotlin
data.aws_caller_identity.current.account_id
```
This avoids hardcoding account IDs.

# 4. Creating IAM Users Dynamically Using for_each
Instead of writing many IAM user blocks, we create all users with one resource:

```hcl
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")

  tags = {
    FullName   = "${each.value.first_name} ${each.value.last_name}"
    Department = each.value.department
    JobTitle   = each.value.job_title
  }
}
```
This creates usernames like jdoe, slee, mstone.

# 5. Creating IAM Groups
```hcl
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/"
}

resource "aws_iam_group" "managers" {
  name = "Managers"
  path = "/"
}

resource "aws_iam_group" "engineers" {
  name = "Engineers"
  path = "/"
}
```
# 6. Assigning Users to Groups Based on Department
Education Group
```hcl
resource "aws_iam_user_group_membership" "education" {
  group = aws_iam_group.education.name

  users = [
    for user in aws_iam_user.users :
    user.name if user.tags.Department == "Education"
  ]
}
```

Managers Group
```hcl
resource "aws_iam_user_group_membership" "managers" {
  group = aws_iam_group.managers.name

  users = [
    for user in aws_iam_user.users :
    user.name if user.tags.Department == "Managers"
  ]
}
```

Engineers Group
```hcl
resource "aws_iam_user_group_membership" "engineers" {
  group = aws_iam_group.engineers.name

  users = [
    for user in aws_iam_user.users :
    user.name if user.tags.Department == "Engineers"
  ]
}
```

# 7. Creating IAM Login Profiles — Allowing Console Login
```hcl
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
    ]
  }
}
```
Optional output:

```hcl
output "user_passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => "Password created - user must reset on first login"
  }
  sensitive = true
}
```

# Conclusion
We have now completed Day 16 of the challenge:

Prepared a CSV file

Decoded it using csvdecode()

Created IAM users dynamically

Assigned users to groups based on departments

Created login profiles for console access
