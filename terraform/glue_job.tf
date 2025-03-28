resource "aws_security_group" "glue_sg" {
  vpc_id = aws_vpc.main.id
  name = "dbt-data-vault-glue-sg"

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "dbt-data-vault-glue-sg"
  }
}

module "glue_job" {
  source = "./glue_job"
  aurora_cluster = module.dbt_data_vault.aurora_cluster
  stage = var.stage
  subnet = aws_subnet.public_subnet
  bucket = aws_s3_bucket.bucket
  aurora_credentials_secret_arn = module.dbt_data_vault.aurora_credentials_secret_arn
  aws_account_id = var.aws_account_id
  glue_sg = aws_security_group.glue_sg
}