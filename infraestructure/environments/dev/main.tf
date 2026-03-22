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

  project_name      = var.project_name
  environment       = var.environment
  music_bucket_name = module.music_storage.bucket_id
  music_bucket_arn  = module.music_storage.bucket_arn

  timeout            = 10
  memory_size        = 128
  log_retention_days = 7

  tags = var.tags
}
