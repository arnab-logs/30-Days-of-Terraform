# Day:09 AWS Terraform Lifecycle Rules

Welcome to Day Nine of our **30 Days of AWS Terraform** journey! Today, we’re diving into **Terraform Lifecycle Rules** — a set of powerful tools that help you control how resources are created, updated, or destroyed.  

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-34-day-09-aws-terraform-lifecycle-rules)

Think of lifecycle rules as gentle guides for Terraform, ensuring your infrastructure behaves exactly the way you want, safely and predictably.

---

## Why Lifecycle Rules Matter

When managing AWS resources with Terraform:

- Updating an **EC2 AMI** could inadvertently cause downtime if not handled properly.  
- An **S3 bucket** storing critical data could be accidentally deleted.  
- External changes, like scaling an **Auto Scaling Group**, might conflict with Terraform’s configuration.

Lifecycle rules help us:

- **Minimize downtime** during updates  
- **Prevent accidental deletions** of critical resources  
- **Respect external changes** without overwriting them unnecessarily

---

## Lifecycle Rule 1: `create_before_destroy`

**Purpose:** Ensure Terraform creates a new resource **before** destroying the old one.  

**Why it matters:** Prevents downtime for applications, like an EC2 instance, when updating configurations.  

**Example:**

```hcl
resource "aws_instance" "day_09_ec2" {
  ami           = "ami-0d176f79571d18a8f"
  instance_type = var.allowed_vm_types[0]
  region        = tolist(var.allowed_region)[0]
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
```
Behavior:

true: Creates new instance first, then destroys old one → minimal downtime

false: Destroys old instance first, then creates new → potential downtime if errors occur

## Lifecycle Rule 2: prevent_destroy
Purpose: Safeguard critical resources from accidental deletion.

Example:

```hcl
resource "aws_s3_bucket" "critical_bucket" {
  bucket = "my-critical-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
```
Behavior: Terraform blocks deletion unless explicitly overridden. Perfect for S3 buckets, production EC2 instances, or databases.

## Lifecycle Rule 3: ignore_changes
Purpose: Allows certain resource properties to change outside Terraform without being overwritten.

Scenario:

An Auto Scaling Group is set to desired capacity 2 in Terraform.

Someone manually changes it to 3 in AWS Console.

Without ignore_changes → Terraform resets it to 2.
With ignore_changes → Terraform respects manual updates, avoiding conflicts.

```hcl
lifecycle {
  ignore_changes = [desired_capacity]
}
```
## Lifecycle Rule 4: replace_triggered_by
Purpose: Automatically replace dependent resources when a related resource changes.

Example:

An S3 bucket stores logs

A logging configuration sends logs to the bucket

```hcl
Copy code
resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-app-logs"
  acl    = "private"
}

resource "aws_s3_bucket_logging" "log_config" {
  bucket        = aws_s3_bucket.log_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "logs/"

  lifecycle {
    replace_triggered_by = [aws_s3_bucket.log_bucket.id]
  }
}
```
Behavior: If the S3 bucket changes, Terraform automatically replaces the logging configuration, keeping resources in sync.

## Lifecycle Rules 5 & 6: Preconditions & Postconditions
Preconditions
Run before creating a resource

Validates conditions, stops creation if not met

```hcl
lifecycle {
  precondition {
    condition     = contains(["us-east-1", "us-west-2"], aws_instance.example.availability_zone)
    error_message = "Resource must be in allowed region."
  }
}
```
Postconditions
Run after resource creation

Ensures compliance or correctness

```hcl
lifecycle {
  postcondition {
    condition     = contains(keys(aws_s3_bucket.example.tags), "compliance")
    error_message = "Bucket must have a compliance tag."
  }
}
```
Why they matter: They act as safety checks, preventing mistakes and enforcing organizational rules automatically.
