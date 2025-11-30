    # Task 1: String Constraint
    variable "environment" {
    type    = string
    default = "dev"
    }

    variable "region" {
    type    = string
    default = "us-east-1"
    }

    # Task 2: Number Constraint
    variable "instance_count" {
    type        = number
    description = "Number of EC2 instances to create"
    default     = 2
    }

    # Task 3: Boolean Constraint
    variable "monitoring_enabled" {
    type    = bool
    default = true
    }

    variable "associate_public_ip" {
    type    = bool
    default = true
    }

    # Task 4: List(string) Constraint (CIDR blocks)
    variable "cidr_block" {
    type    = list(string)
    default = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
    }

    # Task 5: List(string) Constraint (allowed VM types)
    variable "allowed_vm_types" {
    type    = list(string)
    default = ["t2.micro", "t2.small", "t3.micro", "t3.small"]
    }

    # Task 6: Set(string) Constraint (allowed regions)
    variable "allowed_region" {
    type    = set(string)
    default = ["us-east-1", "us-west-2", "eu-west-1"]
    }

    # Task 7: Map(string) Constraint (tags)
    variable "tags" {
    type    = map(string)
    default = { Environment = "dev", Name = "dev-Instance", created_by = "terraform" }
    }

    # Task 8: Tuple Constraint (ingress values)
    variable "ingress_values" {
    type    = tuple([number, string, number])
    default = [443, "tcp", 443]
    }

    # Task 9: Object Constraint (config)
    variable "config" {
    type = object({
        region         = string
        monitoring     = bool
        instance_count = number
    })
    default = { region = "us-east-1", monitoring = true, instance_count = 1 }
    }
