# Day 21 – AWS Policy and Governance with Terraform  

Full Blog Post: [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-46-day-21-aws-policy-and-governance-setup-using-terraform)

## Introduction

Welcome back to **30 Days of AWS Terraform** 👋  

In the previous phase of this journey, we focused on building **custom Terraform modules for EKS**, learning how real-world teams structure infrastructure code for reuse and long-term maintainability.

On **Day 21**, the journey takes a very natural and important turn.

As infrastructure grows and more people start working in the same AWS environment, it’s no longer enough to just *create* resources. We also need to make sure those resources are used **safely, consistently, and responsibly**.

That’s where **AWS Policy and Governance** come in.

In this mini project, we implement a **real-world audit, security, and compliance setup** using Terraform—exactly the kind of foundation you’d expect to see inside an organization.

---

## What This Project Is About

This project demonstrates how to set up **policy enforcement and governance controls** on AWS using Terraform in a clean, automated, and repeatable way.

By the end of this setup, we are able to:

- **Prevent risky actions** before they happen  
- **Detect non-compliant resources** after they’re created  
- **Maintain a secure audit trail** of everything happening in the AWS account  

All infrastructure, policies, and governance rules are managed **as code**.

---

## Policy vs Governance (High-Level Idea)

Understanding the difference between **policy** and **governance** is key.

### 🔒 Policy (Prevention)
Policies are **guardrails**.  
They stop unsafe actions *before* they happen.

Examples:
- Block S3 object deletion unless MFA is enabled  
- Deny uploads to S3 unless HTTPS is used  
- Prevent EC2 creation without required tags  

These are enforced using **IAM policies**.

---

### 👀 Governance (Visibility & Accountability)
Governance is about **observing and recording**.

It answers questions like:
- Are resources following security standards?
- What changed, and when?
- Which resources are compliant or non-compliant?

This is handled using **AWS Config**, which continuously evaluates resources and records their state.

---

## Project Structure

```

day21/
├── provider.tf        # AWS provider configuration
├── variables.tf       # Input variables
├── main.tf            # S3 audit bucket and shared resources
├── iam.tf             # IAM policies, roles, and users
├── config.tf          # AWS Config recorder, delivery channel, and rules
├── outputs.tf         # Output values
└── README.md          # Documentation

```

---

## Laying the Foundation: Secure Audit S3 Bucket

Before enforcing rules or checking compliance, we create a **secure S3 bucket** that acts as the backbone of governance.

This bucket is used to store:
- AWS Config logs  
- Compliance and non-compliance data  
- Configuration history over time  

### Key Security Features
- ✅ **Unique bucket name** with random suffix  
- 🏷️ **Tags** for identification and organization  
- 🗂️ **Versioning enabled** to preserve history  
- 🔐 **Server-side encryption** for data at rest  
- 🚫 **Public access fully blocked**  
- 🔒 **HTTPS-only access enforced** via bucket policy  

This ensures audit data is **private, protected, and reliable**.

---

## Enforcing Guardrails with IAM Policies

IAM policies are used to **block risky actions upfront**.

### 1️⃣ MFA Required for S3 Object Deletion
- Denies `s3:DeleteObject` if MFA is not present
- Uses an explicit **Deny**, which always takes priority

### 2️⃣ Enforce Encryption in Transit for S3
- Denies `s3:PutObject` when HTTPS is not used
- Ensures all data is transferred securely

### 3️⃣ Require Tags on EC2 Creation
- Enforces mandatory tags:
  - `Environment` (dev, staging, prod)
  - `Owner`
- Prevents untagged resources from being created

### Demo IAM User
A demo IAM user is created to clearly observe how these policies behave with and without proper configuration (e.g., MFA).

---

## Introducing AWS Config (Governance Layer)

IAM policies prevent mistakes, but they don’t tell us **what already exists** or **what drifted over time**.

AWS Config fills this gap.

### AWS Config Components
- **IAM Role** – Allows AWS Config to operate in the account  
- **Configuration Recorder** – Captures resource changes  
- **Delivery Channel** – Sends data to the secure S3 audit bucket  

Once enabled, AWS Config continuously monitors the environment.

---

## AWS Config Rules (Compliance Monitoring)

Config rules evaluate resources and mark them as **compliant or non-compliant**.

### Rules Used in This Project
- ❌ S3 Public Write Prohibited  
- 🔐 S3 Encryption Enabled  
- 🚫 S3 Public Read Prohibited  

These are **AWS-managed rules**, making setup simple and reliable.

They don’t block resources—but they give clear visibility into what needs fixing.

---

## How Everything Fits Together

- IAM Policies **prevent unsafe actions**
- AWS Config **records everything**
- Config Rules **evaluate compliance**
- Audit data is stored **securely in S3**

This combination mirrors how **real organizations manage security and governance at scale**.

---

## Key Takeaways

- Policy and governance solve different problems—and work best together  
- Terraform makes security and compliance **repeatable and auditable**  
- Preventing mistakes is good; **detecting drift is just as important**  
- A secure audit trail is foundational for real-world cloud environments  

---

## What’s Next?

This is just one layer of real-world infrastructure governance.

In the upcoming days, we’ll continue building on this foundation—exploring deeper Terraform patterns, refining workflows, and connecting these ideas to everyday DevOps practices.

📅 **Onward to Day 22!**  
Let’s keep learning, one layer at a time.
```
