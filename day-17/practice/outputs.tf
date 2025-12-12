output "application_name" {
  description = "Name of the Elastic Beanstalk application"
  value       = aws_elastic_beanstalk_application.app.name
}

output "blue_environment_name" {
  description = "Blue (Production) environment name"
  value       = aws_elastic_beanstalk_environment.blue.name
}

output "blue_environment_url" {
  description = "Blue environment URL"
  value       = "http://${aws_elastic_beanstalk_environment.blue.cname}"
}

output "blue_environment_cname" {
  description = "CNAME of Blue environment"
  value       = aws_elastic_beanstalk_environment.blue.cname
}

output "green_environment_name" {
  description = "Green (Staging) environment name"
  value       = aws_elastic_beanstalk_environment.green.name
}

output "green_environment_url" {
  description = "Green environment URL"
  value       = "http://${aws_elastic_beanstalk_environment.green.cname}"
}

output "green_environment_cname" {
  description = "CNAME of Green environment"
  value       = aws_elastic_beanstalk_environment.green.cname
}

output "s3_bucket" {
  description = "S3 bucket for app versions"
  value       = aws_s3_bucket.app_versions.id
}

output "swap_command" {
  description = "AWS CLI swap command"
  value       = <<-EOT
    aws elasticbeanstalk swap-environment-cnames \
      --source-environment-name ${aws_elastic_beanstalk_environment.blue.name} \
      --destination-environment-name ${aws_elastic_beanstalk_environment.green.name} \
      --region ${var.aws_region}
  EOT
}

output "instructions" {
  description = "Deployment instructions"
  value       = <<-EOT
    
    ========================================
    Day-17-Demo Blue-Green Deployment
    ========================================
    
    1. CHECK BLUE ENV (v1.0)
       URL: ${aws_elastic_beanstalk_environment.blue.cname}

    2. CHECK GREEN ENV (v2.0)
       URL: ${aws_elastic_beanstalk_environment.green.cname}

    3. SWAP CNAMEs
       aws elasticbeanstalk swap-environment-cnames \
         --source-environment-name ${aws_elastic_beanstalk_environment.blue.name} \
         --destination-environment-name ${aws_elastic_beanstalk_environment.green.name}

    4. VERIFY SWAP COMPLETE

    5. ROLLBACK IF NEEDED
       Run swap again.

    ========================================
  EOT
}
