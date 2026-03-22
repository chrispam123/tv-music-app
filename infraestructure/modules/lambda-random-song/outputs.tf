output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.random_song.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.random_song.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function (used by API Gateway)"
  value       = aws_lambda_function.random_song.invoke_arn
}

output "role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for Lambda logs"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
