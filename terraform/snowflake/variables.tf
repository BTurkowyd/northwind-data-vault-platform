# Stage/environment variable (e.g., dev, prod)
variable "stage" {
  description = "The stage name"
  type        = string
}

# IAM role ARN for Snowflake storage integration
variable "snowflake_integration_iam_role" {
  description = "The IAM role for Snowflake integration"
  type        = string
}

# S3 bucket name for storing data vault tables
variable "data_vault_bucket_name" {
  description = "The S3 bucket name for data vault"
  type        = string
}

# S3 location for Iceberg tables
variable "iceberg_tables_location" {
  description = "The S3 location for iceberg tables"
  type        = string
}

# IAM user for Snowflake integration
variable "snowflake_iam_user" {
  description = "The IAM user for Snowflake"
  type        = string
}

# Snowflake user for authentication
variable "snowflake_user" {
  description = "The Snowflake user"
  type        = string
}
