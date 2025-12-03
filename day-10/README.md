# 30 Days of AWS Terraform – Day 10: Terraform Expressions

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-35-day-10-aws-terraform-conditional-expressions-splat-expression-and-dynamic-block)

Welcome back to our 30 Days of AWS Terraform journey! 
Today, we step into **Terraform Expressions** – tiny helpers inside your configuration that let Terraform make decisions, repeat useful blocks, and gather values without extra fuss.  
They’re not full functions (we’ll cover those later), but they make our code cleaner, more reusable, and our work gentler.

---

## Topics Covered

### 1️⃣ Conditional Expressions

**Why Conditional Expressions?**  
When managing infrastructure, we face small but repetitive decisions:

- Should this environment use a small instance or a bigger one?  
- Should this bucket be public or private?  
- Should this feature be ON or OFF?  

Doing this manually invites mistakes. Conditional expressions automate these decisions, telling Terraform:  
> “If this condition is true → pick value A, else → pick value B.”

**Example:**  

- Dev environment → small instance (`t2.micro`)  
- Staging/Prod → larger instance (`t3.micro`)  

```hcl
instance_type = var.environment == "dev" ? "t2.micro" : "t3.micro"
```

This simple one-liner ensures Terraform automatically selects the correct instance type, reducing errors and manual updates.

### 2️⃣ Dynamic Blocks
The Problem:
When creating resources like security groups, we often need multiple similar blocks (e.g., ingress rules). Writing each manually is repetitive and error-prone.

Solution: Dynamic blocks! They act like a mould:

The mould = block structure

The filling = values from a list

Terraform automatically generates as many blocks as needed

Setting up the Input:

```hcl
variable "ingress_rules" {
  description = "List of ingress rules for security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTPS" }
  ]
}
```

Using the Dynamic Block:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules

  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
    description = ingress.value.description
  }
}
```

Benefits:

Avoid repetitive code

Automatically scale with list size

Add/remove rules easily

Keep Terraform files clean and readable

### 3️⃣ Splat Expressions
The Problem:
When working with multiple resources (e.g., multiple buckets, subnets, or instances), we often want all values of a single attribute. Doing it manually is tedious.

The Solution: Splat expressions (*)

Collects a specific attribute from all resources in one line

No loops or extra local variables required

Example with count:

```hcl
resource "aws_s3_bucket" "demo" {
  count  = 3
  bucket = "demo-bucket-${count.index}"
}

output "bucket_names" {
  value = aws_s3_bucket.demo[*].bucket
}
```
Result:

```css
]["demo-bucket-0", "demo-bucket-1", "demo-bucket-2"]
```
Example with for_each:

```hcl
resource "aws_subnet" "example" {
  for_each = {
    public1  = "10.0.1.0/24"
    public2  = "10.0.2.0/24"
    private1 = "10.0.3.0/24"
  }

  cidr_block = each.value
  vpc_id     = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.example[*].id
}
```

Terraform gathers all IDs into a single list automatically.

When to Use Splat Expressions:

Multiple resources exist

Need one attribute from all resources

Want cleaner, shorter, readable Terraform code

### Key Takeaways
Conditional Expressions: Let Terraform choose values automatically based on simple conditions

Dynamic Blocks: Generate repeated blocks dynamically without manual repetition

Splat Expressions: Collect a single attribute from multiple resources in one line

Together, these expressions make Terraform code cleaner, scalable, and easier to maintain.
