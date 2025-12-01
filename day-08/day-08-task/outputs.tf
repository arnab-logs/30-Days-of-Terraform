#Output all bucket names (from Task 1)
output "count_bucket_names" {
  value = [for b in aws_aws_s3_bucket.count_buckets : b.bucket]
}

#Output all bucket IDs (from Task 2)
output "for_each_bucket_ids" {
  value = [for b in aws_aws_s3_bucket.for_each_buckets : b.id]
}

