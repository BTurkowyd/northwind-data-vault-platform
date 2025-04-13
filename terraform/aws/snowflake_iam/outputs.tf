output "snowflake_integration_iam_role" {
  value       = aws_iam_role.snowflake_role.arn
  description = "The IAM role ARN for Snowflake integration"
}
