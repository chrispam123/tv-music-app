# Lambda Random Song Function Module

Terraform module that creates an AWS Lambda function to generate presigned URLs for random music files from an S3 bucket.

## Resources Created

- Lambda function with Python 3.11 runtime
- IAM role and policies for Lambda execution and S3 access
- CloudWatch Log Group for function logs

## Required Inputs

- `project_name`: Project name for resource naming
- `environment`: Environment name (dev, prod)
- `music_bucket_name`: Name of S3 bucket with music files
- `music_bucket_arn`: ARN of S3 bucket with music files

## Optional Inputs

- `timeout`: Function timeout in seconds (default: 10)
- `memory_size`: Function memory in MB (default: 128)
- `log_retention_days`: Log retention period (default: 7)

## Outputs

- `function_name`: Lambda function name
- `function_arn`: Lambda function ARN
- `invoke_arn`: Invoke ARN for API Gateway integration
- `role_arn`: IAM role ARN
- `log_group_name`: CloudWatch Log Group name
