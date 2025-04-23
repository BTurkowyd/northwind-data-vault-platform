output "snowflake_integration_iam_role" {
  value = module.snowflake.snowflake_integration_iam_role
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "glue_job_name" {
  value = module.northwind_glue_job.glue_job_name
}
