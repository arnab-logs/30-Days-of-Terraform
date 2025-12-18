
# Day 20: Terraform Custom Modules for EKS

## Introduction
Welcome back to Day 20 of our **30 Days of AWS Terraform** journey.  

Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-45-day-20-aws-terraform-modules)

Last day, we explored how Terraform provisioners help us go beyond simply declaring infrastructure and how they allow us to bridge that small but important gap between creating resources and actually preparing them for real use.  

With only 10 days left in our 30-day challenge, it feels like the perfect moment to start thinking about **structure, organization, and reusability**.  

Up until now, most of our Terraform work lived comfortably inside a single folder, with files like `main.tf`, `variables.tf`, and `outputs.tf` sitting together and doing their job. That approach is fine when experimenting, but as projects grow, we naturally ask: *how do we keep this clean, reusable, and manageable?*  


By the end of this blog, we’ll have infrastructure that’s thoughtfully designed, reusable, and easy to extend.

---

## What are Modules?
Before we talk about custom modules, it’s important to understand **Terraform modules**.  

At its core, a module in Terraform is simply a **reusable piece of code**. It’s a way of grouping Terraform configuration so we can use it again without rewriting the same logic over and over.  

Terraform isn’t a fully-fledged programming language. While it has built-in functions, it doesn’t allow defining custom functions the way Python or Java does. When we want **reuse of entire infrastructure logic**, Terraform gives us **modules** instead.  

Modules let us:
- Package infrastructure logic together
- Encapsulate complexity
- Reuse code across projects
- Interact with the module using only inputs and outputs

For example, a VPC module can include subnets, route tables, and gateways. Instead of writing all of this repeatedly, a module allows us to define it once and reuse it.

---

## Types of Modules
Terraform modules broadly fall into three categories:

1. **Public Modules**  
   - Maintained by Terraform providers like AWS, GCP, Azure  
   - Solve common infrastructure problems in a standardized way  
   - Example: VPC, EKS, IAM modules  

2. **Partner Modules**  
   - Maintained by organizations officially partnered with HashiCorp  
   - Follow certain standards agreed upon with HashiCorp  
   - Sit between community contributions and official provider-backed modules  

3. **Custom Modules**  
   - Created and maintained by us, our team, or organization  
   - Can be published to GitHub, versioned, and evolved over time  
   - Offer full control over design and lifecycle  
   - Useful for locking values and enforcing standards in production  

---

## How Terraform Organizes Modules
- Every Terraform project lives inside a **module**.  
- The **root module** is the top-level configuration folder where `terraform init`, `plan`, and `apply` run.  
- As projects grow, we break things into smaller **custom modules**, each responsible for one part of infrastructure:  
  - `modules/vpc/` → networking  
  - `modules/eks/` → Kubernetes cluster  
  - `modules/iam/` → IAM roles and policies  
  - `modules/secrets/` → Secrets Manager setup  

Each module has familiar files: `main.tf`, `variables.tf`, `outputs.tf`.  

- The **root module orchestrates everything**  
- Custom modules **focus on doing one thing well**  
- Root module passes values to modules (inputs)  
- Modules return outputs back to root  

This relationship is like calling a function with parameters: root module provides inputs, module executes logic, and returns outputs.

---

## First Module: VPC

### Project Layout
```

code/               ← root module
└── modules/
└── vpc/        ← custom VPC module

```

### Step 1: Writing the VPC logic inside the custom module
Inside `modules/vpc/main.tf` we define the VPC resource logic, using variables instead of hardcoded values.

### Step 2: Declaring what the module expects
Inside `modules/vpc/variables.tf`, we declare:

```

variable "vpc_cidr" {}
variable "name_prefix" {}

```
No values assigned—just expectations.

### Step 3: Defining values in the root module
Inside `code/variables.tf`, we assign values that the module will use.

### Step 4: Calling the custom module from the root module
Inside `code/main.tf`:

```

module "vpc" {
source      = "./modules/vpc"
name_prefix = var.cluster_name
vpc_cidr    = var.vpc_cidr
}

```

- `module "vpc"` → instance of the custom module  
- `source` → module folder path  
- Values passed in → inputs to the module  

At this point:
- VPC logic is encapsulated
- Root module is clean and readable
- Module can be reused anywhere
- Changes are controlled by modifying the module itself

---

## Extending the VPC Module: Subnets and Availability Zones
1. **Decision**: Root module decides availability zones, module consumes them.  
2. **Fetch AZs** in root module via a data source.  
3. **Pass AZs** to the module as variables.  
4. **Declare variables** inside `modules/vpc/variables.tf`.  
5. **Use values** in `modules/vpc/main.tf` to create public subnets.  

Result:
- Root module controls decisions
- Module executes logic
- Inputs/outputs create a clean contract  
- Any future changes (regions, AZs, subnet layouts) only require input updates, not module changes  

**This is the real power of custom modules.**

---

## Summary
- Modules are reusable containers for Terraform code  
- They **encapsulate complexity**, making large projects manageable  
- Public, partner, and custom modules exist, with custom modules giving full control  
- Root module orchestrates, custom modules handle specific tasks  
- Clear input/output contracts between modules make projects production-ready  

By understanding this, we’re ready to build infrastructure that’s clean, reusable, and easy to extend. Custom modules are the backbone of scalable, production-grade Terraform projects.

---

