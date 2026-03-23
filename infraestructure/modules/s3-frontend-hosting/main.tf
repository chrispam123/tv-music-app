# S3 Frontend Hosting Module
# Creates S3 bucket configured for static website hosting

# S3 bucket for frontend
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

# Website configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Public access block configuration (allow public read)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read access
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
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
