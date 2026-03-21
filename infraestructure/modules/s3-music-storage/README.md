# S3 Music Storage Module

Creates an S3 bucket for storing music files that the Lambda function serves to the TV app.

## Features

- Encrypted at rest (AES256)
- Public access blocked (only accessible via signed URLs)
- Optional versioning
- Configurable prefix for music files organization

## Usage


module "music_storage" {
  source = "../../modules/s3-music-storage"

  project_name        = "tv-music-app"
  environment         = "dev"
  music_files_prefix  = "music-files"
  enable_versioning   = false
  
  tags = {
    Team = "Platform"
  }
}


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | - | yes |
| environment | Environment (dev/prod) | string | - | yes |
| music_files_prefix | Folder for music files | string | "music-files" | no |
| enable_versioning | Enable bucket versioning | bool | false | no |
| tags | Additional tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | Bucket name |
| bucket_arn | Bucket ARN |
| bucket_domain_name | Bucket domain |
| music_files_prefix | Music files prefix |

