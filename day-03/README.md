# Day 3 of #30DaysOfAWSTerraform: Creating Your First S3 Bucket

Hello, dear reader! Welcome to Day 3 of our #30DaysOfAWSTerraform journey. Today, we take a gentle step forward and focus on something small but significant: creating your very first AWS resource using Terraform — an S3 bucket. This is where our code begins to manifest into something real and tangible, and we’ll take it slowly, step by step.

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-28-day-03-our-first-aws-resource-with-terraform-creating-an-s3-bucket)


---

## Setting Up Today’s Workspace

Before we start, let’s set the stage:

1. Create a new folder for today’s work. You can name it anything you like; I’m using `Day-03`.
2. Inside this folder, create a file named `main.tf`. Terraform isn’t strict about filenames, but keeping them simple helps maintain clarity as your projects grow.

Now, let’s start with the familiar — the **provider block**. This tells Terraform which cloud provider we’re using (AWS) and which region we’ll work in. Here’s what it looks like in `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
```

Even though we’re beginning something new, this block reminds us that we are building on what we learned previously.

---

## Writing the S3 Bucket Block

Now comes the exciting part: creating our first S3 bucket with Terraform. But before we dive in, it’s helpful to understand how Terraform documentation works. The documentation guides us on:

* Which fields are required
* Which fields are optional
* How to safely add customization like tags

For today, we’ll follow the **“private bucket with tags”** example.

Open the Terraform AWS provider documentation for S3 buckets [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) and search for **S3** or **AWS S3**. Look at the examples, and check the argument reference to see what is needed.

Here’s our S3 bucket configuration in `main.tf`:

```hcl
resource "aws_s3_bucket" "day3_bucket" {
  bucket = "arnab-day3-terraform"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

### Breaking it down:

* **Resource block**: Terraform expects every resource to start with a `resource` block.
* **aws_s3_bucket**: This tells Terraform we want an S3 bucket in AWS.
* **day3_bucket**: The internal name used to refer to this resource within Terraform. You can name it anything meaningful.
* **bucket = "arnab-day3-terraform"**: The unique name of the bucket in AWS. S3 bucket names must be unique across all regions.
* **tags**: Simple key-value pairs to help organize your resources. We’ve added `Name` and `Environment` for now.

That’s it! Once saved, we’re ready to let Terraform bring it to life.

---

## Creating the S3 Bucket with Terraform

With our configuration ready, we now initialize Terraform. Open the terminal in the `Day-03` folder and run:

```bash
terraform init
```

This step sets up the provider plugin and prepares Terraform to communicate with AWS. Think of it like placing all the props on stage before a play begins.

Next, we run a **dry run** to see what Terraform plans to create:

```bash
terraform plan
```

Terraform will output the planned actions — in our case, one S3 bucket to be added. Nothing has been changed yet, so this is a safe step.

When ready, we apply the configuration:

```bash
terraform apply
```

Terraform will prompt:

```
Do you want to perform these actions?
```

Typing `yes` creates the bucket in AWS. If you’d like to skip the prompt, use:

```bash
terraform apply --auto-approve
```

After a few seconds, our bucket exists in AWS! Open the AWS console, navigate to S3, and you’ll see it listed.

---

## Updating and Managing Our S3 Bucket

Seeing your resource in AWS is satisfying. Now let’s explore small changes. For example, we might want to rename the bucket or update tags:

```hcl
bucket = "arnab-day3-bucket"
```

After saving the change, run:

```bash
terraform plan
```

Terraform compares the new configuration with the actual state in AWS and shows what will change. Then, apply the changes:

```bash
terraform apply
```

The bucket updates exactly as specified, without touching the console manually. This illustrates Terraform’s **predictable and controlled workflow**.

---

## Destroying the Bucket

Sometimes, we need to remove a resource. To destroy the bucket:

```bash
terraform destroy
```

Terraform will ask for confirmation:

```
Do you really want to destroy these resources?
```

Typing `yes` removes the bucket. To skip this prompt:

```bash
terraform destroy --auto-approve
```

In seconds, the bucket is gone. Gentle, predictable, and safe.

---

## Summary

Today, we completed a full Terraform cycle:

1. `terraform init` → prepares Terraform
2. `terraform plan` → previews changes
3. `terraform apply` → creates resources
4. `terraform modify` → updates resources
5. `terraform destroy` → removes resources

These are the major commands every beginner should know before exploring more advanced workflows. With this, we’ve not only created our first S3 bucket but also learned how Terraform safely manages cloud infrastructure.

---

**Next Steps:** In upcoming blogs, we’ll explore more Terraform concepts and gradually create more complex infrastructure. 
