output "bucket_name" {
  description = "Name of the frontend hosting bucket"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN of the frontend hosting bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "website_endpoint" {
  description = "Website endpoint URL (use this to access the frontend)"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "website_url" {
  description = "Full HTTP URL of the website"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}
