#Task-01: Understanding count
resource "aws_s3_bucket" "count_buckets" {
    count = length(var.arnab_day08_bucket)
    bucket = var.arnab_day08_bucket[count.index]
    tags = {
      Environment = "Dev"
    }
}

#Task-02: Understanding for_each
resource "aws_s3_bucket" "for_each_buckets" {
    for_each = var.arnab_bucket_set
    bucket = each.value
    tags = {
      "Environment" = "Dev"
    }
  
}

