resource "snowflake_storage_integration" "s3_integration" {
  name             = "S3_INTEGRATION_${var.stage}"
  storage_provider = "S3"
  enabled          = true
  storage_allowed_locations = [
    "s3://${var.data_vault_bucket_name}/athena_results/northwind/tables/northwind_data_vault"
  ]
  storage_aws_role_arn = var.snowflake_integration_iam_role
}

resource "snowflake_stage" "s3_stage" {
  name                = "S3_STAGE_${var.stage}"
  directory           = "ENABLE = true"
  database            = snowflake_database.my_db.name
  schema              = snowflake_schema.northwind_schema.name
  url                 = "s3://${var.data_vault_bucket_name}/athena_results/northwind/tables/northwind_data_vault"
  storage_integration = snowflake_storage_integration.s3_integration.name

  file_format = "TYPE = PARQUET NULL_IF = []"
}
