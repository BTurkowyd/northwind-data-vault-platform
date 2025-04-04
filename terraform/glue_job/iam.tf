# AWS Glue role
resource "aws_iam_role" "glue_role" {
  name = "glue_role_${var.raw_data_directory}_${var.stage}"
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
  name       = "glue_s3_access_${var.raw_data_directory}_${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "glue_rds_access" {
  name       = "glue_rds_access_${var.raw_data_directory}_${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_policy" "glue_get_connection_policy" {
  name        = "glue_get_connection_policy_${var.raw_data_directory}_${var.stage}"
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
          "glue:GetTable",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:CreateDatabase"
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
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  name       = "glue_logging_${var.raw_data_directory}_${var.stage}"
}

resource "aws_iam_policy" "glue_secretsmanager_policy" {
  name        = "glue_secretsmanager_policy_${var.raw_data_directory}_${var.stage}"
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
  name        = "glue_vpc_access_${var.raw_data_directory}_${var.stage}"
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
  name = "get_caller_identity_policy_${var.raw_data_directory}_${var.stage}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_caller_identity_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.get_caller_identity_policy.arn
}
