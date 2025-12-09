terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# S3 Bucket

resource "aws_s3_bucket" "day_14_demo_bucket" {
  bucket_prefix = "day-14-demo-${var.bucket_prefix}"
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "day_14_demo" {
  bucket = aws_s3_bucket.day_14_demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Origin Access Control (OAC)

resource "aws_cloudfront_origin_access_control" "day_14_demo_oac" {
  name                              = "day-14-demo-oac"
  description                       = "OAC for Day-14 demo static website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# S3 Bucket Policy for CloudFront

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
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.day_14_demo_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.day_14_demo_distribution.arn
          }
        }
      }
    ]
  })
}

# Upload Website Files

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

# CloudFront Distribution

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
