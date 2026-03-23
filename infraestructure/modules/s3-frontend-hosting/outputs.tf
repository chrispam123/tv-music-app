output "bucket_name" {
  description = "Name of the frontend hosting bucket"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN of the frontend hosting bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the bucket (for CloudFront origin)"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}
