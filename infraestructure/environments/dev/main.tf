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

