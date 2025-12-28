
# Day 14: Hosting a Static Website with S3 and CloudFront Using Terraform

**Full Blog Post:** [Read on Hashnode](https://learning-out-loud-my-devops-journey.hashnode.dev/day-39-day-14-aws-terraform-hosting-a-static-website-using-aws-s3-and-cloudfront)

Hello and welcome back!

If you’ve been following the series, you know that yesterday, on Day 13, we spent time exploring Terraform data sources. We saw how Terraform can fetch information from AWS and reuse it, helping us keep our configurations clean, organized, and dynamic.

And today, we finally begin that “something bigger.”

This is Day 14 of 30 Days of AWS Terraform, and until now, we’ve been learning concepts one by one. But from today onward, we’re stepping into real mini-projects.

To start this phase, we’ll tackle a project that many beginners find comforting: hosting a static website using an S3 bucket, with CloudFront in front of it. We may have tried this manually in the AWS console at some point i.e. uploading HTML files to a bucket, enabling static website hosting, maybe even connecting a domain. But doing all of this with Terraform is different, and it shows how we can automate and manage infrastructure efficiently.

Before we dive into code, it’s important to understand what we’re building and why it matters. CloudFront and S3 aren’t just two AWS services placed together, they solve real problems. For example, when our website has visitors from different parts of the world, these services work together to make the website secure, fast, and cost-efficient, all while keeping the S3 bucket private.


## Understanding S3 + CloudFront Together

Before touching Terraform code, let’s understand why we need S3 and CloudFront and how they work together:

- **Global visitors:** Your website may have users in India, the US, Australia, Latin America, Europe, etc.
- **Challenges without CloudFront:**
  - **Cost:** Data transfer fees increase when users are far from the S3 bucket.
  - **Performance:** Long-distance file requests slow down page loading.
  - **Security:** Public buckets expose your content to potential attacks.

**CloudFront** solves these challenges by serving files from **edge locations** close to users:

- **Faster delivery:** Cached files at edge locations reduce load times.
- **Lower cost:** Data travels shorter distances, reducing transfer fees.
- **Better security:** Users never access the S3 bucket directly.

Each cached file has a **TTL (time to live)**, usually 24 hours. During this period, CloudFront serves repeated requests locally, reducing load on S3.

By combining S3 and CloudFront, we ensure our website is secure, fast, and cost-efficient globally.

---

## 1. Setting Up the S3 Bucket with Terraform

Now that we understand why we’re using S3 and CloudFront together, let’s move into the “how.”

We start with the S3 bucket — the place where all website files will live. Using Terraform:

```hcl
resource "aws_s3_bucket" "day_14_demo_bucket" {
  bucket_prefix = "day-14-demo-${var.bucket_prefix}"
}

resource "aws_s3_bucket_public_access_block" "day_14_demo" {
  bucket = aws_s3_bucket.day_14_demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

Explanation:

aws_s3_bucket creates the bucket.

bucket_prefix ensures a unique name.

aws_s3_bucket_public_access_block makes the bucket private and blocks public access.

Configuring Origin Access Control and Bucket Policy

## 2. Origin Access Control (OAC)
CloudFront needs secure access to the private bucket:

```hcl
resource "aws_cloudfront_origin_access_control" "day_14_demo_oac" {
  name                              = "day-14-demo-oac"
  description                       = "OAC for Day-14 demo static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

Explanation:

Ensures CloudFront authenticates requests to the private S3 bucket.

Uses AWS SigV4 signing for secure access.

## 3. S3 Bucket Policy
Define permissions so only CloudFront can read files:

```hcl
resource "aws_s3_bucket_policy" "day_14_demo_policy" {
  bucket = aws_s3_bucket.day_14_demo_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.day_14_demo,
    aws_cloudfront_distribution.day_14_demo_distribution
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudFrontAccess"
        Effect   = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.day_14_demo_bucket.arn}/*"]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.day_14_demo_distribution.arn
          }
        }
      }
    ]
  })
}
```

## 4. Uploading Static Website Files
Terraform makes uploading files simple:

```hcl
resource "aws_s3_object" "day_14_demo_files" {
  for_each = fileset("${path.module}/www", "**/*")

  bucket = aws_s3_bucket.day_14_demo_bucket.id
  key    = each.value
  source = "${path.module}/www/${each.value}"
  etag   = filemd5("${path.module}/www/${each.value}")

  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    gif  = "image/gif"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
    txt  = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
```

Explanation:

Loops through all files in the www folder.

Uploads each file to the S3 bucket with correct content_type.

etag ensures updates are detected automatically.

## 5. Creating the CloudFront Distribution
CloudFront delivers content quickly and securely:

```hcl
resource "aws_cloudfront_distribution" "day_14_demo_distribution" {
  origin {
    domain_name              = aws_s3_bucket.day_14_demo_bucket.bucket_regional_domain_name
    origin_id                = "day-14-demo-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.day_14_demo_oac.id
  }

  enabled         = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "day-14-demo-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

Explanation:

origin points to the private S3 bucket.

Configures caching, allowed methods, and HTTPS enforcement.

price_class reduces cost by limiting edge locations.

CloudFront serves the site fast and securely worldwide.

## 6. Terraform Outputs
Outputs make it easy to access important information:

```hcl
output "day_14_demo_website_url" {
  description = "CloudFront URL for the Day-14 demo website"
  value       = "https://${aws_cloudfront_distribution.day_14_demo_distribution.domain_name}"
}

output "day_14_demo_cloudfront_distribution_id" {
  description = "CloudFront distribution ID for Day-14 demo"
  value       = aws_cloudfront_distribution.day_14_demo_distribution.id
}

output "day_14_demo_s3_bucket_name" {
  description = "S3 bucket name for Day-14 demo"
  value       = aws_s3_bucket.day_14_demo_bucket.bucket
}
```

What they give us:

Website URL — access your live site.

<img width="2914" height="1758" alt="image" src="https://github.com/user-attachments/assets/17acb343-9574-460a-b6aa-6076b92ba697" />

CloudFront distribution ID — manage or update the distribution.

S3 bucket name — reference the private bucket easily.

## Conclusion

With this, we have completed Day 14 of our 30-day AWS Terraform journey. Today was our first demo session, seeing an S3 bucket and CloudFront in action.
