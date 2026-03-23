# Outputs from S3 module
output "music_bucket_name" {
  description = "Name of the S3 bucket containing music files"
  value       = module.music_storage.bucket_id
}

output "music_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.music_storage.bucket_arn
}

# Outputs from Lambda module
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.random_song_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.random_song_lambda.function_arn
}

# Outputs from API Gateway module
output "api_endpoint" {
  description = "Base endpoint of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "api_invoke_url" {
  description = "Full invoke URL for the API (use this to test with curl)"
  value       = module.api_gateway.stage_invoke_url
}
# Outputs from Frontend Hosting module
output "frontend_website_url" {
  description = "URL to access the frontend in TV browser"
  value       = module.frontend_hosting.website_url
}

output "frontend_bucket_name" {
  description = "Name of the frontend hosting bucket"
  value       = module.frontend_hosting.bucket_name
}
