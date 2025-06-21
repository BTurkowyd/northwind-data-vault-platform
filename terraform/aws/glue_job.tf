resource "aws_security_group" "glue_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.repo_name}-glue-sg"

  # Allow all TCP traffic within the security group (self-referencing)
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  # Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.repo_name}-glue-sg"
  }
}

# Glue job module for Northwind ETL
module "northwind_glue_job" {
  source                        = "./glue_job"
  aurora_cluster                = module.northwind.aurora_cluster
  aurora_credentials_secret_arn = module.northwind.aurora_credentials_secret_arn
  bucket                        = aws_s3_bucket.bucket
  glue_sg                       = aws_security_group.glue_sg
  stage                         = var.stage
  subnet                        = aws_subnet.public_subnet
  raw_data_directory            = "northwind_iceberg"
}
