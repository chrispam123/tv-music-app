# Backend configuration for Terraform state
# guardo mi estado a S3

terraform {
  backend "s3" {
    bucket = "tv-music-app-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"

    # DynamoDB table for state locking
    # NOTA: Comentado intencionalmente - se habilitará cuando se implemente CI/CD
    # Ver: docs/architecture/decisions/003-defer-dynamodb-locking.md
    # dynamodb_table = "tv-music-app-terraform-locks"

    # Encryption configuration
    encrypt = true

    # Use the tv-music-dev profile for AWS credentials
    # profile removed - uses AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY env vars in CI/CD
    # For local development, use: export AWS_PROFILE=tv-music-dev
  }
}
