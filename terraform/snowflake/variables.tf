variable "stage" {
  description = "The stage name"
  type        = string
}

variable "snowflake_integration_iam_role" {
  description = "The IAM role for Snowflake integration"
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
