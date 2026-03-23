# API Gateway Module
# Creates HTTP API that exposes Lambda function as public endpoint

# HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "HTTP API for ${var.project_name} - ${var.environment} environment"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api"
      Environment = var.environment
    },
    var.tags
  )
}

# Lambda integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Route for GET /
resource "aws_apigatewayv2_route" "get_random_song" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage (auto-deploy)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      protocol         = "$context.protocol"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api-stage"
      Environment = var.environment
    },
    var.tags
  )
}

# CloudWatch Log Group for API Gateway logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api-logs"
      Environment = var.environment
    },
    var.tags
  )
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
