# S3 Frontend Hosting Module
# Creates private S3 bucket for CloudFront origin

# S3 bucket for frontend (private)
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-${var.environment}-frontend"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-frontend"
      Environment = var.environment
    },
    var.tags
  )
}

# Block all public access (bucket is private)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy - allow access only from CloudFront
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# Upload frontend files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.module}/../../../frontend/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../../frontend/index.html")
}

resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "css/styles.css"
  source       = "${path.module}/../../../frontend/css/styles.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/../../../frontend/css/styles.css")
}

resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "js/app.js"
  source       = "${path.module}/../../../frontend/js/app.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/../../../frontend/js/app.js")
}
