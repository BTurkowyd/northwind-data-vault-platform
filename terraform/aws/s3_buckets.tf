# S3 bucket for scripts, raw data, and Data Vault storage
resource "aws_s3_bucket" "bucket" {
  bucket        = "northwind-${lower(random_id.bucket_suffix.b64_url)}-${var.stage}-${var.aws_account_id}"
  force_destroy = true

  tags = {
    Name = "${var.repo_name}-bucket-${var.stage}"
  }
}

# Random suffix for bucket name to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 24
}
