# Main infrastructure configuration for development environment
# This file will call modules to create actual infrastructure resources

# TODO: Add module calls here (Lambda, S3, API Gateway, CloudFront)
# Main infrastructure configuration for development environment
# Recurso temporal para validar que el backend remoto funciona
# Main infrastructure configuration for development environment

# S3 bucket for music file storage
module "music_storage" {
  source = "../../modules/s3-music-storage"

  project_name       = "tv-music-app"
  environment        = "dev"
  music_files_prefix = "music-files"
  enable_versioning  = false # No versioning needed in dev

  tags = {
    ManagedBy = "Terraform"
  }
}
# Lambda function for random song selection
module "random_song_lambda" {
  source = "../../modules/lambda-random-song"

  project_name             = var.project_name
  environment              = var.environment
  music_bucket_name        = module.music_storage.bucket_id
  music_bucket_arn         = module.music_storage.bucket_arn
  music_bucket_kms_key_arn = module.music_storage.kms_key_arn


  timeout            = 10
  memory_size        = 128
  log_retention_days = 7

  tags = var.tags
}

# API Gateway for exposing Lambda function
module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name         = var.project_name
  environment          = var.environment
  lambda_function_name = module.random_song_lambda.function_name
  lambda_invoke_arn    = module.random_song_lambda.invoke_arn



  cors_allow_origins = ["*"]
  log_retention_days = 7

  tags = var.tags
}

# Frontend hosting on S3
module "frontend_hosting" {
  source = "../../modules/s3-frontend-hosting"

  project_name = var.project_name
  environment  = var.environment

  tags = var.tags
}
