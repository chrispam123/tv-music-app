# CloudFront Distribution Module

Terraform module for creating CloudFront distribution with Origin Access Control for secure S3 static website hosting.

## Resources Created

- CloudFront distribution with HTTPS enabled
- Origin Access Control (OAC) for secure S3 access
- Cache behaviors optimized for static content

## Required Inputs

- `project_name`: Project name
- `environment`: Environment name
- `s3_bucket_name`: Name of origin S3 bucket
- `s3_bucket_regional_domain_name`: Regional domain of S3 bucket

## Outputs

- `distribution_url`: HTTPS URL to access the site (use this instead of S3 URL)

## Security

- Forces HTTPS (redirect-to-https)
- S3 bucket should be private, accessed only via OAC
