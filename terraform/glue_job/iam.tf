# AWS Glue role
resource "aws_iam_role" "glue_role" {
  name = "glue_role_dbt_data_vault${var.stage}"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "glue.amazonaws.com",
          },
          Action = "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "Glue Role for dbt Data Vault"
  }
}

resource "aws_iam_policy_attachment" "glue_s3_access" {
  name       = "glue-s3-access-dbt-data-vault-${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "glue_rds_access" {
  name       = "glue-rds-access-dbt-data-vault-${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}