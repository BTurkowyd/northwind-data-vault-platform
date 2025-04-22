variable "stage" {
  description = "The stage in which the resources will be created"
  default     = "dev"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  default     = "926728314305"
}

variable "snowflake_external_id" {
  description = "The external ID from Snowflake"
  type        = string
}

variable "snowflake_account_arn" {
  description = "The IAM user ARN from Snowflake integration (STORAGE_AWS_IAM_USER_ARN)"
  type        = string
}

variable "repo_name" {
  description = "The name of the repository"
  type        = string
}
