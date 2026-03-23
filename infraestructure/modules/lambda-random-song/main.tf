# Lambda Random Song Function Module
# Creates Lambda function that generates presigned URLs for random music files
# Package the Lambda function code into a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../backend/random-song-function/src"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-random-song-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-lambda-random-song-role"
      Environment = var.environment
    },
    var.tags
  )
}

# Attach AWS managed policy for basic Lambda execution (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for S3 access to music bucket
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.project_name}-${var.environment}-lambda-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.music_bucket_arn,
          "${var.music_bucket_arn}/*"
        ]
      },

      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.music_bucket_kms_key_arn
      }

    ]
  })
}

# Lambda function resource
resource "aws_lambda_function" "random_song" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-random-song"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = {
      MUSIC_BUCKET_NAME = var.music_bucket_name
    }
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-random-song"
      Environment = var.environment
    },
    var.tags
  )
}

# CloudWatch Log Group for Lambda function logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.random_song.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-lambda-logs"
      Environment = var.environment
    },
    var.tags
  )
}
