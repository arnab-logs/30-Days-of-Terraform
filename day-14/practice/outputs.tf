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
