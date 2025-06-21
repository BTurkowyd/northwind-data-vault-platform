# IAM Role for AWS Glue job execution
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

# Attach AmazonS3FullAccess policy to Glue role for S3 access
resource "aws_iam_policy_attachment" "glue_s3_access" {
  name       = "glue_s3_access_${var.raw_data_directory}_${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach AmazonRDSFullAccess policy to Glue role for Aurora access
resource "aws_iam_policy_attachment" "glue_rds_access" {
  name       = "glue_rds_access_${var.raw_data_directory}_${var.stage}"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Custom policy to allow Glue to manage Glue Catalog and Tables
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

# Attach the Glue Catalog policy to the Glue role
resource "aws_iam_role_policy_attachment" "glue_get_connection_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_get_connection_policy.arn
}

# Attach CloudWatch logging policy for Glue job logs
resource "aws_iam_policy_attachment" "glue_logging" {
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  name       = "glue_logging_${var.raw_data_directory}_${var.stage}"
}

# Custom policy to allow Glue to retrieve credentials from Secrets Manager
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

# Attach the Secrets Manager policy to the Glue role
resource "aws_iam_role_policy_attachment" "glue_secretsmanager_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_secretsmanager_policy.arn
}

# Custom policy to allow Glue to access VPC resources (ENIs, subnets, etc.)
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

# Attach the VPC access policy to the Glue role
resource "aws_iam_role_policy_attachment" "glue_vpc_access_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_vpc_access.arn
}

# Policy to allow Glue to call sts:GetCallerIdentity (useful for debugging and AWS SDKs)
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

# Attach the GetCallerIdentity policy to the Glue role
resource "aws_iam_role_policy_attachment" "get_caller_identity_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.get_caller_identity_policy.arn
}
