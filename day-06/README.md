# 30 Days of AWS Terraform – Day 6: Terraform Project Structure

Welcome to Day Six of our 30 Days of AWS Terraform journey! In today’s session, we focused on **organizing Terraform projects** to make our infrastructure code cleaner, safer, and easier to maintain.

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-31-day-06-aws-terraform-project-structure-and-best-practices)

---

## What We Learned Today

### 1. From One File to Many

* Until now, all resources, variables, and configurations were in a single `main.tf` file.
* Keeping everything together is fine for beginners but becomes hard to manage as projects grow.
* Splitting the project into multiple files improves readability and maintainability.

### 2. The Root Module

* The root module is simply the top-level project folder.
* Commonly recommended files include:

  * `main.tf` → resource definitions
  * `variables.tf` → input variables
  * `outputs.tf` → outputs
  * `versions.tf` → Terraform version requirements
  * `providers.tf` → provider configuration
  * `backend.tf` → backend configuration
  * `terraform.tfvars` → actual variable values (sensitive, **do not upload**)
  * `terraform.tfvars.example` → template for public use
  * `.gitignore` → prevents sensitive/unnecessary files from being uploaded
  * `README.md` → project guide

### 3. Keeping Things Clean

* Certain files (like `terraform.tfvars` or `.terraform/`) should stay local to protect sensitive data.
* Use `.gitignore` to ensure Git does not track unnecessary files.
* Use `terraform.tfvars.example` as a safe, shareable template.

### 4. When Projects Grow

* Projects naturally become more complex with more resources or multiple teams.
* Two common approaches to handle growth:

  1. **Separate folders for each environment** (dev, staging, prod).
  2. **Single set of files with multiple `.tfvars` files** for environment-specific values.
* Both approaches are valid; choose what fits your workflow.

---

## Summary

By organizing Terraform files thoughtfully, we make projects **easier to read, safer to maintain, and ready for growth**. Today’s session laid the foundation for clean project structure, preparing us for more advanced topics in the next steps.

---

## Next Steps

* Apply this file structure to your Day 06 folder.
* Ensure sensitive files are protected with `.gitignore`.
* Explore multiple environments or `.tfvars` separation as projects grow.

Thanks for following along, and see you in **Day 7: Type Constraints**!
