
# Day 15: AWS VPC Peering with Terraform

Hello and welcome back to **30 Days of AWS Terraform**. 

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-40-day-15-aws-vpc-peering-using-terraform)

Today is **Day 15**, and if you’ve been following this journey from the start, congratulations — we’ve made it halfway! 🎉  

Staying consistent while learning new technology takes curiosity and effort. Take a moment to appreciate yourself for showing up and sticking with it.  

---

## Recap of Previous Days

Over the past few days, we moved from understanding basic Terraform concepts to trying out mini projects:  

- **Day 13-14:** Hosted a static website on **AWS S3**  
- Integrated **CloudFront** to distribute the website globally  

These projects showed how Terraform can manage real AWS infrastructure and how small changes can have a big impact.  

Today, we move a step forward: **AWS VPC Peering using Terraform**. Networking concepts like VPC peering can feel intimidating at first, but we’ll take it slow and understand **why it’s needed** and **how it works**.

---

## What VPC Peering Really Is

VPC peering allows two **VPCs** (Virtual Private Clouds) to communicate privately without going over the public internet.  

Key points to remember:  

- **Bidirectional:** Traffic flows both ways (A → B and B → A).  
- **Non-overlapping CIDR ranges:** Each VPC must have a unique IP range.  
- **No transitive peering:** A → B and B → C does **not** automatically allow A → C. Each pair requires its own peering connection.

---

## Example Scenario

- **Primary VPC (A):** `10.0.0.0/16`  
- **Secondary VPC (B):** `10.1.0.0/16`  

Steps to enable communication:  

1. Request a peering connection from **A → B**  
2. Accept the request on **B → A**  

Now, both VPCs can communicate securely and privately.  

> ⚠️ Transitive Peering: Adding a third VPC (C) does not allow automatic communication from A → C. You must create a direct peering connection for each pair.

---

## Terraform Setup for Multi-Region VPC Peering

### Providers

We need **two providers** for multi-region setup:

```hcl
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

region tells Terraform which AWS region to use.

alias lets Terraform know which provider to use for each resource.

## Variables
Define variables to make our configuration reusable:

```hcl
variable "primary_region" { default = "us-east-1" }
variable "secondary_region" { default = "us-west-2" }

variable "primary_vpc_cidr" { default = "10.0.0.0/16" }
variable "secondary_vpc_cidr" { default = "10.1.0.0/16" }
Regions: Where the VPCs will be created
```

## CIDR blocks: Unique address ranges for each VPC

Planning the Network
We’ll create:

Primary VPC (us-east-1)

Subnet

Internet Gateway

Route Table

Security Group

Secondary VPC (us-west-2)

Subnet

Internet Gateway

Route Table

Security Group

# VPC Peering Connection linking the two VPCs and updating route tables

## Creating Primary and Secondary VPCs
Primary VPC
```hcl
resource "aws_vpc" "primary_vpc" {
  provider             = aws.primary
  cidr_block           = var.primary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "Primary-VPC-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}
```
cidr_block: IP range for the VPC

enable_dns_*: Friendly names for instances

tags: Organize resources

## Primary Subnet
```hcl
resource "aws_subnet" "primary_subnet" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "Primary-Subnet-${var.primary_region}", Environment = "Demo" }
}
```

map_public_ip_on_launch: Instances get public IPs automatically

availability_zone: Dynamically fetched

## Internet Gateway

```hcl
resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id
  tags     = { Name = "Primary-IGW", Environment = "Demo" }
}
```

## Route Table
```hcl
resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.primary_igw.id }
  tags = { Name = "Primary-Route-Table", Environment = "Demo" }
}

resource "aws_route_table_association" "primary_rta" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}
```
## Secondary VPC
Configured the same way as Primary, but:

cidr_block = "10.1.0.0/16"

Provider = aws.secondary

# Creating the VPC Peering Connection
## Request (Primary → Secondary)
```hcl
resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = var.secondary_region
  auto_accept = false
  tags = {
    Name        = "Primary-to-Secondary-Peering"
    Environment = "Demo"
    Side        = "Requester"
  }
}
```

## Accept (Secondary → Primary)
```hcl
resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true
  tags = {
    Name        = "Secondary-Accepter"
    Environment = "Demo"
    Side        = "Accepter"
  }
}
```

## Update Route Tables
```hcl
resource "aws_route" "primary_to_secondary" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  depends_on = [aws_vpc_peering_connection_accepter.secondary_accepter]
}

resource "aws_route" "secondary_to_primary" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  depends_on = [aws_vpc_peering_connection_accepter.secondary_accepter]
}
```

# EC2 Instances & Security Groups
## Security Groups
```hcl
resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  vpc_id      = aws_vpc.primary_vpc.id
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP from Secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }
  ingress {
    description = "All traffic from Secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## EC2 Instances
```hcl
resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name
  user_data              = local.primary_user_data
  depends_on             = [aws_vpc_peering_connection_accepter.secondary_accepter]
}
```
user_data installs a simple Nginx webpage showing region & private IP.

Secondary instance is configured similarly.

## Testing Connectivity
SSH into each EC2 instance

Ping the private IP of the other instance

Use curl to check Nginx webpage on the other instance

✅ Successful ping = ICMP works
✅ Webpage loads = TCP works across VPCs

## Clean Up
Remember to destroy Terraform resources after testing to avoid unnecessary AWS charges:

```bash
terraform destroy
```
Conclusion
We’ve successfully:

Created multi-region VPCs
Set up VPC Peering

Launched EC2 instances with security groups

Verified private communication between instances
