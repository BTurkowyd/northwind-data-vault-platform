variable "stage" {
  description = "The stage name"
  type        = string
}

variable "snowflake_integration_iam_role" {
  description = "The IAM role for Snowflake integration"
  type        = string
}

variable "data_vault_bucket_name" {
  description = "The S3 bucket name for data vault"
  type        = string
}

variable "iceberg_tables_location" {
  description = "The S3 location for iceberg tables"
  type        = string
}

variable "snowflake_iam_user" {
  description = "The IAM user for Snowflake"
  type        = string
}

variable "snowflake_user" {
  description = "The Snowflake user"
  type        = string
}
