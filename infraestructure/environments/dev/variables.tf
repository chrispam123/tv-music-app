variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "tv-music-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "tv-music-app"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
