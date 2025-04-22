# s3 bucket for scripts, raw data and data vault
resource "aws_s3_bucket" "bucket" {
  bucket        = "northwind-${lower(random_id.bucket_suffix.b64_url)}-${var.stage}-${var.aws_account_id}"
  force_destroy = true

  tags = {
    Name = "${var.repo_name}-bucket-${var.stage}"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 24
}
