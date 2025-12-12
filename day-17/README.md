# Day 17 — Blue‑Green Deployment with Terraform + Elastic Beanstalk

Welcome back to Day 17 of our **30 Days of AWS Terraform** journey.

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-42-day-17-aws-terraform-blue-green-deployment-using-elastic-beanstalk)

Today, we’re opening a new chapter — something practical, something used by real teams every single day, yet something that can feel intimidating when we first hear its name: **blue-green deployment**.

---

## What is Blue/Green Deployment?

If that phrase feels a bit heavy, that’s okay. Most things in tech sound complicated before someone explains them. And that’s exactly what we’re going to do today: breathe through it and understand it like a story.

It’s a concept that might sound big but is actually just a simple idea wrapped in a slightly fancy name. By the time we reach the end, we’ll see how naturally all the pieces fit.

Our mini-project today uses **AWS Elastic Beanstalk** and **Terraform** to create two separate environments: blue and green. We’ll package a small application, upload it to **S3**, create application versions, and watch how each environment gets its own version of the app. The most interesting part comes later, where with a simple “swap,” traffic can gently shift from one environment to the other, giving us a sense of how real deployments happen with almost no downtime.

So take a breath, settle in, and let’s begin our slow and steady walk into the world of blue-green deployments together.

---

### Fact #17

During my school and college years, drawing little sketches and doodles was something I kept coming back to. It was a hobby I really enjoyed.

---

## Understanding Blue‑Green Deployment (A simple story)

Before we dive into any Terraform blocks or AWS resources, let’s take a pause. I want you to imagine something simple.

Picture our application as a cozy little café. Our customers walk in, take a seat, enjoy the calm atmosphere, and everything just… works. This café is our **blue** environment — the one everyone knows, trusts, and uses every day.

Now, suppose we want to renovate: update the menu, repaint the walls, or try new lighting. Doing that while customers are seated? Stressful and risky. Instead, we quietly build an identical café next door — same furniture, same setup. This second café is our **green** environment. It’s empty, peaceful, and safe to experiment in.

In the green café we test improvements without disturbing anyone. Only when everything feels perfect do we gently swap the entrances. From the outside the signboard (our DNS name) is the same — customers walk in without noticing anything changed. The old blue café becomes the standby. If needed, we swap back.

In real applications, this is how blue-green deployment works: blue is production, green is the duplicate staging environment, and swap is the seamless transition.

---

## Preparing S3 and Application Packaging

Every application needs a home where its packaged files live before deployment. In our case, that home is an S3 bucket — a storage room for different versions of the application, each carefully labeled.

The first step is uploading our application package to this bucket. The package is a zip file named `app-v1.zip` — like an envelope containing the app. Terraform uploads this envelope to S3 so Elastic Beanstalk can pull it and create an application version.

The Terraform snippet from the notes looks like this:

```
  resource "aws_s3_object" "app_v1" {
    bucket = aws_s3_bucket.app_versions.id
    key    = "app-v1.zip"
    source = "${path.module}/app-v1/app-v1.zip"
    etag   = filemd5("${path.module}/app-v1/app-v1.zip")
  
    tags = var.tags
  }
```

A small resource doing a small job, but it sets everything else in motion. Without this file in S3, Elastic Beanstalk wouldn’t know where to pull the application version from.

---

## Blue Environment Details

With the application package in S3, we define an Elastic Beanstalk application version and then the blue environment — our production environment carrying version `1.0`.

Application version Terraform block from the notes:

```
  resource "aws_elastic_beanstalk_application_version" "v1" {
    name        = "${var.app_name}-v1"
    application = aws_elastic_beanstalk_application.app.name
    description = "Application Version 1.0 - Initial Release"
    bucket      = aws_s3_bucket.app_versions.id
    key         = aws_s3_object.app_v1.id
  
    tags = var.tags
  }
```

And the blue environment definition:

```
  resource "aws_elastic_beanstalk_environment" "blue" {
    name                = "${var.app_name}-blue"
    application         = aws_elastic_beanstalk_application.app.name
    solution_stack_name = var.solution_stack_name
    tier                = "WebServer"
    version_label       = aws_elastic_beanstalk_application_version.v1.name
```

This environment includes many settings — IAM instance profile, service role, instance type, load balancer, autoscaling, health reporting, environment variables, and tags. A few examples from the notes:

```
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = aws_iam_instance_profile.eb_ec2_profile.name
    }
```

```
    setting {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "ServiceRole"
      value     = aws_iam_role.eb_service_role.name
    }
```

```
    setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = var.instance_type
    }
```

```
    setting {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "EnvironmentType"
      value     = "LoadBalanced"
    }
```

```
    setting {
      namespace = "aws:autoscaling:asg"
      name      = "MinSize"
      value     = "1"
    }
```

```
    setting {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "SystemType"
      value     = "enhanced"
    }
```

```
    setting {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = "ENVIRONMENT"
      value     = "blue"
    }
```

And tags merged with environment information:

```
    tags = merge(
      var.tags,
      {
        Environment = "blue"
        Role        = "production"
      }
    )
  }
```

All these pieces create a reliable, secure, and scalable blue environment ready to serve users.

---

## Green Environment Details

The green environment is created similarly to blue but will host the newer application version (v2). The pattern is the same: identical configuration, different version_label. Deploy changes on green, test thoroughly, and when ready, perform the swap to make green live.

---

## IAM Roles and Profiles

Elastic Beanstalk needs IAM roles for EC2 instances and for the Beanstalk service itself. These roles enable instances to access S3, perform updates, and scale.

EC2 role from the notes:

```
  resource "aws_iam_role" "eb_ec2_role" {
    name = "${var.app_name}-eb-ec2-role"
  
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    })
  
    tags = var.tags
  }
```

We attach managed policies:

```
  resource "aws_iam_role_policy_attachment" "eb_web_tier" {
    role       = aws_iam_role.eb_ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
  }
```

And create an instance profile:

```
  resource "aws_iam_instance_profile" "eb_ec2_profile" {
    name = "${var.app_name}-eb-ec2-profile"
    role = aws_iam_role.eb_ec2_role.name
  
    tags = var.tags
  }
```

The Elastic Beanstalk service role is defined similarly, allowing the service to perform actions on our behalf and attaching policies for health and managed updates.

---

## App Versions, Deployment Flow, and Swap

With blue and green in place, each running its own version, the swap toggles traffic between them by updating DNS behind the scenes. This lets us:

* Test safely on green without affecting users.
* Minimize downtime when switching.
* Roll back quickly by swapping back to blue if needed.

The swap is the heart of blue-green deployment — a simple, safe mechanism for confident releases.

---

## Demo: Version 1.0 and Version 2.0

In the demo flow from the notes:

* The blue environment responds: “Welcome to the blue green deployment demo. This is version 1.0.”
* The green environment responds: “It is in the status staging and these are the new features released in version v2.0.”

Blue is live with v1.0; green is staging with v2.0. When ready, swap to make green live.

---

## Rollback and Destroy

If something goes wrong after the swap, swapping again restores traffic to blue immediately. When the demo is complete, running `terraform destroy` cleans up the resources.

This tidy workflow helps beginners keep their accounts organized and reinforces a disciplined deployment practice.

---

## Closing Thoughts

Thank you for walking through this slow, story-driven exploration of blue-green deployment. Take your time practicing these steps; hands-on experience is the best way to build confidence. Happy Terraforming!

