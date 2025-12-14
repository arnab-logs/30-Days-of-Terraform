
# Day 18 – Serverless Image Processing with AWS Lambda & Terraform

## Introduction

Welcome to **Day 18 of the 30 Days of AWS Terraform** series.

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-43-day-18-aws-terraform-image-processing-serverless-project-using-aws-lambda)

In the previous day, we worked with **Blue-Green Deployment using Elastic Beanstalk**, which involved long-running infrastructure.  
Today, we shift gears and explore the **serverless side of AWS** using **AWS Lambda**.

This project demonstrates how Terraform can be used to build an **event-driven image processing pipeline** where code runs **only when needed**.

---

## What We’re Building

An automated image processing workflow using:

- AWS S3 (source and destination buckets)
- AWS Lambda (serverless image processor)
- Lambda Layers (Pillow library)
- IAM roles and policies (least privilege)
- CloudWatch Logs
- Terraform for infrastructure provisioning

---

## High-Level Flow

```

Upload Image
|
v
S3 Source Bucket
|
| (S3 Event)
v
AWS Lambda
(Image Processing)
|
v
S3 Destination Bucket
(Processed Images)

```

---

## Image Processing Output

When an image is uploaded, Lambda generates:

- JPEG (85% quality)
- JPEG (60% quality)
- WebP
- PNG
- Thumbnail (200×200)

---

## Repository Structure

```

day-18/
├── lambda/
│   └── lambda_function.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── pillow_layer.zip
├── scripts/
│   ├── deploy.sh
│   └── build_layer_docker.sh

````

---

## Core Terraform Resources

### Random Suffix for Unique Names

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}
````

---

### Local Values

```hcl
locals {
  bucket_prefix         = "${var.project_name}-${var.environment}"
  upload_bucket_name    = "${local.bucket_prefix}-upload-${random_id.suffix.hex}"
  processed_bucket_name = "${local.bucket_prefix}-processed-${random_id.suffix.hex}"
  lambda_function_name  = "${var.project_name}-${var.environment}-processor"
}
```

---

### S3 Buckets

```hcl
resource "aws_s3_bucket" "upload_bucket" {
  bucket = local.upload_bucket_name
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = local.processed_bucket_name
}
```

(Versioning, encryption, and public access blocks are enabled for both buckets.)

---

### IAM Role and Policy for Lambda

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "${local.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
```

```hcl
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.processed_bucket.arn}/*"
      }
    ]
  })
}
```

---

### Lambda Layer (Pillow)

```hcl
resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/pillow_layer.zip"
  layer_name          = "${var.project_name}-pillow-layer"
  compatible_runtimes = ["python3.12"]
}
```

---

### Lambda Function

```hcl
resource "aws_lambda_function" "image_processor" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 1024

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.id
    }
  }
}
```

---

### S3 Event Trigger

```hcl
resource "aws_lambda_permission" "allow_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}
```

```hcl
resource "aws_s3_bucket_notification" "upload_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
```

---

## Deployment

Run the deployment script:

```bash
cd scripts
chmod +x deploy.sh
./deploy.sh
```

This script:

* Builds the Pillow Lambda layer using Docker
* Initializes Terraform
* Plans and applies the infrastructure

---

## Testing

Upload an image to the source bucket:

```bash
aws s3 cp image.jpg s3://<upload-bucket-name>/
```

Processed images will appear in the destination bucket automatically.

---

## Key Takeaways

* Lambda runs **only when events occur**
* Terraform can manage **serverless infrastructure**
* IAM least privilege is critical
* Reading and understanding code is part of learning
* Hands-on practice builds confidence

---

Happy Terraforming 
