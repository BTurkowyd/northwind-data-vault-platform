resource "snowflake_storage_integration" "s3_integration" {
  name             = "s3_integration"
  storage_provider = "S3"
  enabled          = true
  storage_allowed_locations = [
    "s3://your-bucket/path/"
  ]
}
