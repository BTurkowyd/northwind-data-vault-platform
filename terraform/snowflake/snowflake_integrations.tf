resource "snowflake_storage_integration" "s3_integration" {
  name             = "s3_integration"
  storage_provider = "S3"
  enabled          = true
  storage_allowed_locations = [
    "s3://ecommerce-bucket-dev-926728314305-q1c4tvebvzy7chgggfuyva/northwind_data_vault/northwind_data_vault/"
  ]
}
