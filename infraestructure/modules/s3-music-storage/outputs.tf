# Outputs from S3 Music Storage module
# Values that other modules can reference

output "bucket_id" {
  description = "The ID (name) of the S3 bucket"
  value       = aws_s3_bucket.music_storage.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.music_storage.arn
}

output "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = aws_s3_bucket.music_storage.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.music_storage.bucket_regional_domain_name
}

output "music_files_prefix" {
  description = "The prefix where music files are stored"
  value       = var.music_files_prefix
}
output "kms_key_id" {
  description = "The ID of the KMS key used for encryption"
  value       = aws_kms_key.s3_encryption.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.s3_encryption.arn
}

