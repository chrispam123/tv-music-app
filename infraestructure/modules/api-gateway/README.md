# API Gateway Module

Terraform module that creates an HTTP API Gateway to expose Lambda functions as public HTTP endpoints.

## Resources Created

- HTTP API Gateway with CORS configuration
- Lambda integration with AWS_PROXY mode
- Route for GET / endpoint
- Auto-deploying default stage
- CloudWatch Log Group for access logs
- Lambda permission for API Gateway invocation

## Required Inputs

- `project_name`: Project name for resource naming
- `environment`: Environment name (dev, prod)
- `lambda_function_name`: Name of Lambda to invoke
- `lambda_invoke_arn`: Invoke ARN of Lambda function

## Optional Inputs

- `cors_allow_origins`: CORS allowed origins (default: ["*"])
- `log_retention_days`: Log retention period (default: 7)

## Outputs

- `api_endpoint`: Base API endpoint URL
- `stage_invoke_url`: Full invoke URL (use this in frontend)
