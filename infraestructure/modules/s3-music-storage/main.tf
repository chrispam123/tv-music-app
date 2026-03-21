# S3 Music Storage Module
# Creates an S3 bucket to store music files for the TV app

# Construct bucket name using project and environment
# Format: projectname-environment-music-storage
locals {
  bucket_name = "${var.project_name}-${var.environment}-music-storage"
}

# Main S3 bucket resource
resource "aws_s3_bucket" "music_storage" {
  bucket = local.bucket_name

  tags = merge(
    {
      Name        = local.bucket_name
      Purpose     = "Music file storage"
      Environment = var.environment
    },
    var.tags
  )
}
# Bucket versioning configuration
resource "aws_s3_bucket_versioning" "music_storage" {
  bucket = aws_s3_bucket.music_storage.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "music_storage" {
  bucket = aws_s3_bucket.music_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# Block all public access to the bucket
# Music files should only be accessible via signed URLs from Lambda
resource "aws_s3_bucket_public_access_block" "music_storage" {
  bucket = aws_s3_bucket.music_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

