variable "snowflake_external_id" {
  description = "The external ID from Snowflake"
  type        = string
}

variable "snowflake_account_arn" {
  description = "The IAM user ARN from Snowflake integration (STORAGE_AWS_IAM_USER_ARN)"
  type        = string
}

variable "stage" {
  description = "The stage name in Snowflake"
  type        = string
}

variable "data_vault_bucket" {
  description = "The S3 bucket name for data vault"
  type        = string
}
