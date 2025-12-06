# Instance type with validations
variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "Instance type must be between 2 and 20 characters."
  }

  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "Instance type must start with T2 or T3."
  }
}

# Backup name validation
variable "backup_name" {
  default = "mydata-backup"

  validation {
    condition     = endswith(var.backup_name, "-backup")
    error_message = "Backup name must end with '-backup'."
  }
}

# Sensitive variable example
variable "db_password" {
  type      = string
  sensitive = true
  default   = "SuperSecret123"
}

# List of regions with validation
variable "allowed_regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]

  validation {
    condition = alltrue([
      for r in var.allowed_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]$", r))
    ])
    error_message = "Each region must follow AWS region format (e.g., us-east-1)."
  }
}

# List for type conversion example
variable "user_locations" {
  type    = list(string)
  default = ["us-east-1", "us-west-2", "us-east-1"]
}
