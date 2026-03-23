# S3 Frontend Hosting Module

Terraform module for hosting static frontend files on S3 with public website access.

## Resources Created

- S3 bucket configured for static website hosting
- Public access configuration allowing HTTP access
- Bucket policy for public read access
- Automatic upload of HTML/CSS/JS files from frontend/ directory

## Required Inputs

- `project_name`: Project name for resource naming
- `environment`: Environment name (dev, prod)

## Outputs

- `website_url`: Full HTTP URL to access the frontend (use this in TV browser)
- `website_endpoint`: S3 website endpoint
- `bucket_name`: Name of the bucket

## File Updates

When frontend files change, Terraform detects changes via file hashes and re-uploads automatically.
