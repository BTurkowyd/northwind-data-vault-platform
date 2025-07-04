# Output the IAM role for Snowflake integration
output "snowflake_integration_iam_role" {
  value = module.snowflake.snowflake_integration_iam_role
}

# Output the S3 bucket name
output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

# Output the Glue job name
output "glue_job_name" {
  value = module.northwind_glue_job.glue_job_name
}
