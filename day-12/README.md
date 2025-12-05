# Day 12 – Terraform Functions (Part 2)

A practical, beginner-friendly guide covering **Validation Functions**, **Sensitive Variables**, **Regex Rules**, **List Validations**, **Type Conversions**, **Number Functions**, **Timestamps**, and **File Handling** in Terraform.  

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-37-day-11-aws-terraform-functions-part-2)

---

## Table of Contents

- [Overview](#overview)  
- [Understanding Validation Functions](#understanding-validation-functions)  
- [Why Validation Goes Inside the Variable Block](#why-validation-goes-inside-the-variable-block)  
- [Validation Example: Checking Length](#validation-example-checking-length)  
- [Validation Example: Checking `t2` / `t3` with Regex](#validation-example-checking-t2--t3-with-regex)  
- [Practical Validation: Backup Name Ending With `-backup`](#practical-validation-backup-name-ending-with--backup)  
- [Sensitive Variables (Why Some Values Stay Hidden)](#sensitive-variables-why-some-values-stay-hidden)  
- [Validations Using Regex (Simple Explanation)](#validations-using-regex-simple-explanation)  
- [Validation Rules for Lists](#validation-rules-for-lists)  
- [Type Conversion Functions (Lists, Sets & Unique Values)](#type-conversion-functions-lists-sets--unique-values)  
- [Number Functions: `sum`, `max`, `min`, `abs`, Average](#number-functions-sum-max-min-abs-average)  
- [Timestamp Functions: `timestamp()` and `formatdate()`](#timestamp-functions-timestamp-and-formatdate)  
- [File Handling Functions (`fileexists`, `file`, `jsondecode`)](#file-handling-functions-fileexists-file-jsondecode)  

---

## Overview

This document summarises the Terraform functions covered in **Day 12** of the series. Each section includes short explanations and examples you can copy into your `.tf` files and experiment with.

---

## Understanding Validation Functions

Validation functions check input values early — *before* Terraform proceeds with plans or applies.  
They help catch mistakes like wrong formats, lengths, or unexpected values, and they allow us to provide helpful, human-friendly error messages.

- Runs at variable-evaluation time (inside variable blocks)  
- Prevents misconfiguration before resources are created or changed

---

## Why Validation Goes Inside the Variable Block

Validation rules belong in the variable declaration because they define constraints that must be satisfied whenever a value is supplied.

```hcl
variable "example" {
  type = string

  validation {
    condition     = length(var.example) > 0
    error_message = "Example must not be empty."
  }
}
```

## Validation Example: Checking Length
This validation ensures an instance_type value is between 2 and 20 characters:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "Instance type must be between 2 and 20 characters."
  }
}
```
If the length is between 2 and 20 → valid

Otherwise → Terraform stops with the provided error message

## Validation Example: Checking t2 / t3 with Regex
Ensure the instance type starts with t2. or t3.:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "Instance type must start with T2 or T3."
  }
}
```

Regex breakdown
^ → start of string

t → must start with t

[2-3] → follow by 2 or 3

\. → a literal dot

Why can()?
can() avoids Terraform throwing an internal error from regex() and instead returns false gracefully when the pattern does not match.

## Practical Validation: Backup Name Ending With -backup
Require backup names to end with -backup:

```hcl
variable "backup_name" {
  default = "mydata-backup"

  validation {
    condition     = endswith(var.backup_name, "-backup")
    error_message = "Backup name must end with '-backup'."
  }
}
```

Valid: mydata-backup

Invalid: backup-mydata, mydata-backup123

This enforces consistent naming and makes searches/automation easier later.

## Sensitive Variables (Why Some Values Stay Hidden)
Some values (passwords, tokens, keys) should not appear in CLI output or logs.

Mark variables as sensitive:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```
Even if exposed in an output, Terraform will hide the value:

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```
Shows: <sensitive> or hidden output

Note: This is not encryption. Values may still appear in the state file (handle with care).

Why it matters

Prevents accidental leaks via screen-sharing or logs

Reduces risk of committing secrets to version control

Adds a safety layer for team collaboration

## Validations Using Regex (Simple Explanation)
Regex allows pattern-based checks such as:

starts with a letter

contains only letters, numbers, hyphens

specific structure like us-east-1

Example: environment names must start with a letter and contain only letters, numbers, and hyphens:

```hcl
variable "env" {
  type = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.env))
    error_message = "Environment name must start with a letter and contain only letters, numbers, and hyphens."
  }
}
```

^ and $ ensure the whole string is matched

[a-zA-Z] first character is a letter

[a-zA-Z0-9-]* rest can be letters, numbers, hyphens

## Validation Rules for Lists
Validate every item in a list using for expressions with alltrue():

```hcl
variable "allowed_regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]

  validation {
    condition = alltrue([
      for r in var.allowed_regions :
      can(regex("^[a-z]{2}-[a-z]+-[0-9]$", r))
    ])
    error_message = "Each region must follow AWS region format (e.g., us-east-1)."
  }
}
```

Iterates every element and validates the pattern

alltrue() ensures every item passes

Why list validation helps

Catches typos across multiple entries

Avoids failed deployments later

Keeps standards consistent

## Type Conversion Functions (Lists, Sets & Unique Values)
Lists can contain duplicates. Converting to a set removes duplicates.

Example variables:

```hcl
variable "user_locations" {
  type    = list(string)
  default = ["us-east-1", "us-west-2", "us-east-1"]
}

variable "default_location" {
  type    = list(string)
  default = ["us-west-2"]
}
```

Concatenate and convert:

```hcl
locals {
  all_locations   = concat(var.user_locations, var.default_location)
  unique_locations = toset(local.all_locations)
}
```
concat() joins lists

toset() removes duplicates

Why this matters

Clean data automatically

Prevents duplicate processing

Simplifies downstream logic

## Number Functions: sum, max, min, abs, Average
Given monthly costs with credits (negative numbers):

```hcl
variable "monthly_costs" {
  default = [100, -50, 200, 75, -50]
}
```
Convert to positive values

```hcl
locals {
  positive_costs = [for cost in var.monthly_costs : abs(cost)]
}
```
Result: [100, 50, 200, 75, 50]

Max / Min

```hcl
locals {
  max_cost = max(local.positive_costs...)
  min_cost = min(local.positive_costs...)
}
```

Total and Average

```hcl
locals {
  total_cost   = sum(local.positive_costs)
  average_cost = local.total_cost / length(local.positive_costs)
}
```
Why number functions matter

Budgeting and cost reports

Metrics and alerts

Decision making based on computed values

## Timestamp Functions: timestamp() and formatdate()
Capture current time:

```hcl
locals {
  current_time = timestamp()
}
```

Example output: 2025-12-05T14:23:45Z (UTC, ISO-8601)

Format a timestamp:

```hcl
locals {
  formatted_time = formatdate("DD-MM-YYYY HH:MM:SS", local.current_time)
}
```

Why timestamps matter

Used in backups and naming

Useful for logs and audits

Helps with versioning

## File Handling Functions (fileexists, file, jsondecode)
Read and decode an external JSON config:

Example config.json:

```json
{
  "database": {
    "host": "db.example.com",
    "port": 5432,
    "username": "admin",
    "password": "secret"
  },
  "api": {
    "endpoint": "https://api.example.com",
    "timeout": 30
  }
}
```
Terraform usage:

```hcl
locals {
  config_data = fileexists("config.json") ? jsondecode(file("config.json")) : {}
}

output "config" {
  value = local.config_data
}
```

fileexists() checks presence

file() reads file contents

jsondecode() turns JSON into a map/object

Fallback {} avoids crashes if missing

Why file functions matter

Keep large configs or secrets outside .tf files

Reuse external configuration or templates

Make Terraform more dynamic and flexible
