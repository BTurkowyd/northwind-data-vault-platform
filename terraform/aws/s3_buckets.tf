# s3 bucket for scripts, raw data and data vault
resource "aws_s3_bucket" "bucket" {
  bucket        = "ecommerce-bucket-${var.stage}-${var.aws_account_id}-${lower(random_id.bucket_suffix.b64_url)}"
  force_destroy = true

  tags = {
    Name = "ecommerce-bucket-${var.stage}"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 16
}
