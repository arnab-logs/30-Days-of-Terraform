# Day 13: AWS Terraform - Data Sources

Hello and welcome back to **Day 13 of 30 Days of AWS Terraform**!  

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-38-day-13-aws-terraform-data-sources)

If you’ve been following along, you know that yesterday we explored **Terraform functions**—small helpers that make configurations cleaner, smarter, and flexible. We took things step by step, understanding not just what these functions do, but why they matter when building real environments.

Today, we’re exploring something extremely useful in real AWS setups: **data sources**.  

Instead of treating them as just another feature to check off, think of data sources as Terraform’s way of observing what **already exists in AWS**, fetching ready-made details, and helping us avoid hardcoding values that might change over time.

By the end of this tutorial, you will understand:  
- Why data sources are needed  
- How to use them in a simple EC2 example  
- How they help in shared environments, like pre-existing VPCs and subnets


## What Exactly Is a Data Source?

Imagine you want to provision a simple **EC2 instance**. It needs a few basic things:  
- Instance type  
- Subnet  
- Tags  
- AMI (Amazon Machine Image)  

An **AMI** is the operating system template for your EC2 instance. Multiple versions exist for Amazon Linux, Ubuntu, CentOS, and more, and they’re updated over time.  

The challenge is: **how do we get the correct AMI ID for Terraform without hardcoding it?**  
Manually copying IDs is fine once, but not sustainable for automation.

**Data sources** solve this. They allow Terraform to fetch the latest resource details automatically.  

---

## A Real-World Scenario: Using Existing Infrastructure

Imagine an organization where multiple teams share the same **VPC** and **subnets**.  
- DevOps, Development, QA, and others all use the same network  
- Subnet 1 and Subnet 2 are already created  

Our task: create a few EC2 instances:  
- 2 in Subnet 1  
- 2 in Subnet 2  

We’re **not creating new VPCs or subnets**. We need to reference the existing ones.  

Data sources allow Terraform to look up these resources dynamically instead of hardcoding IDs, which is critical in environments where multiple teams may modify or rename resources.

---

## Creating the Data Source for the VPC

```hcl
data "aws_vpc" "vpc_name" {
  filter {
    name   = "tag:Name"
    values = ["day-13-vpc"]
  }
}
```

This tells Terraform:  
*"Look through all VPCs and fetch the one tagged 'day-13-vpc'."*

---

## Creating the Data Source for the Subnet

```hcl
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["day-13-subnet"]
  }
  vpc_id = data.aws_vpc.vpc_name.id
}
```

This allows Terraform to reference the correct subnet **inside the fetched VPC**.  

---

## Creating the Data Source for the AMI (Amazon Linux 2)

```hcl
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
```

- `owners = ["amazon"]` ensures official Amazon AMIs  
- `most_recent = true` automatically picks the latest version  
- Filters help narrow down the exact AMI we need  

---

## Creating the EC2 Instance Using Data Sources

```hcl
resource "aws_instance" "name" {
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.shared.id
  tags          = var.tags
}
```

- `ami` uses the data source to always get the latest AMI  
- `instance_type` is simple (`t3.micro`)  
- `subnet_id` references the existing subnet  
- `tags` can include values like `Environment`, `Team`, `Project`  

---

## Running Terraform

1. Initialize Terraform:
```bash
terraform init
```

2. Plan the deployment:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

Notice how Terraform **did not create new VPCs or subnets**, yet the EC2 instance is correctly created using the existing resources and latest AMI.  

> ⚠️ **Reminder:** Destroy the resource after testing to avoid unnecessary costs:  
```bash
terraform destroy
```

---

This wraps up **Day 13**!  

We had our **first hands-on demo** with data sources, fetching VPCs, subnets, and AMIs to create EC2 instances safely in a shared environment. I hope this gave you a real feel for how important hands-on practice is and how it helps solidify concepts.  

---

## References
- [Terraform AWS Data Sources Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources)

---

You can now continue building more complex scenarios by combining data sources and resources for shared environments!
