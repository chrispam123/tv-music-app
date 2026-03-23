output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  description = "Public endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}

output "stage_invoke_url" {
  description = "Full invoke URL for the default stage"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
