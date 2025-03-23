# AWS Glue role
resource "aws_iam_role" "glue_role" {
  name = "glue_role_dbt_data_vault_${var.stage}"
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

resource "aws_iam_policy" "glue_get_connection_policy" {
  name        = "GlueGetConnectionPolicy"
  description = "Allows AWS Glue to retrieve Glue Connections"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:GetConnection",
          "glue:GetConnections",
          "glue:GetDatabase",
          "glue:GetTables",
          "glue:GetTable"
        ]
        Resource = ["arn:aws:glue:eu-central-1:${var.aws_account_id}:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_get_connection_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_get_connection_policy.arn
}

resource "aws_iam_policy_attachment" "glue_logging" {
  name       = "glue-cloudwatch-logging"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "glue_secretsmanager_policy" {
  name        = "GlueSecretsManagerAccessPolicy"
  description = "Allows AWS Glue to retrieve credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.aurora_credentials_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_secretsmanager_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_secretsmanager_policy.arn
}

resource "aws_iam_policy" "glue_vpc_access" {
  name        = "GlueVPCNetworkingPolicy"
  description = "Allows Glue to access resources in a VPC"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcEndpoints",
          "ec2:CreateTags",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_vpc_access_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_vpc_access.arn
}

resource "aws_iam_policy" "get_caller_identity_policy" {
  name        = "GetCallerIdentityPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_caller_identity_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.get_caller_identity_policy.arn
}