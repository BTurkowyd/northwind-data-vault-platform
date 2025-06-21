# Storage integration for Snowflake to access S3 (Iceberg tables)
resource "snowflake_storage_integration" "s3_integration" {
  name             = "S3_INTEGRATION_${var.stage}"
  storage_provider = "S3"
  enabled          = true
  storage_allowed_locations = [
    "${var.iceberg_tables_location}/tables/northwind_data_vault"
  ]
  storage_aws_role_arn = var.snowflake_integration_iam_role
}

# External stage in Snowflake pointing to S3 for Iceberg tables
resource "snowflake_stage" "s3_stage" {
  name                = "S3_STAGE_${var.stage}"
  directory           = "ENABLE = true"
  database            = snowflake_database.my_db.name
  schema              = snowflake_schema.northwind_schema.name
  url                 = "${var.iceberg_tables_location}/tables/northwind_data_vault"
  storage_integration = snowflake_storage_integration.s3_integration.name

  file_format = "TYPE = PARQUET NULL_IF = []"
}
