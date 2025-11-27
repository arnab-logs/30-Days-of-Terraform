
#S3BucketCreation
resource "aws_s3_bucket" "arnab_s3_bucket" {
  bucket = "day-04-task"
}

#VersioningEnabled
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.arnab_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#EncryptionEnabled
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.arnab_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
