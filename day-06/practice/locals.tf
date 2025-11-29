
locals {
    bucket_name = "${var.day_number}-bucket-${var.environment}-${var.region}"
    vpc_name = "${var.environment}-VPC"
}