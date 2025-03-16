resource "aws_security_group" "glue_sg" {
  vpc_id = aws_vpc.main.id

  # Allow Glue workers to communicate with each other
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true  # Allow all traffic within this security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dbt-data-vault-glue-sg"
  }
}

module "glue_job" {
  source = "./glue_job"
  aurora_cluster = aws_rds_cluster.aurora_cluster
  stage = var.stage
  subnet = aws_subnet.subnet1
  bucket = aws_s3_bucket.bucket
  aurora_credentials_secret_arn = aws_secretsmanager_secret.aurora_secret.arn
  aws_account_id = var.aws_account_id
  glue_sg = aws_security_group.glue_sg
}