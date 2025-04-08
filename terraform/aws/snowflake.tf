module "snowflake" {
  source                = "./snowflake_iam"
  data_vault_bucket     = aws_s3_bucket.bucket.bucket
  snowflake_account_arn = var.snowflake_account_arn
  snowflake_external_id = var.snowflake_external_id
  stage                 = var.stage
}
