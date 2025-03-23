# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Allow access from within the VPC

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dbt-data-vault-aurora-sg"
  }
}

resource "aws_security_group_rule" "aurora_ingress_glue" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora_sg.id
  source_security_group_id = aws_security_group.glue_sg.id
}

# Aurora Serverless Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "dbt-data-vault-aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "16.3"
  enable_http_endpoint = true
  database_name          = "ecommerce_db"
  master_username        = "master"
  master_password        = random_password.aurora_password.result
  storage_encrypted      = true
  skip_final_snapshot    = true
  network_type           = "IPV4"
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name

  serverlessv2_scaling_configuration {
    min_capacity             = 0.0
    max_capacity             = 1.0
    seconds_until_auto_pause = 300
  }

  tags = {
    Name = "dbt-data-vault-aurora-cluster"
  }
}

# Aurora DB Instance (Required for the Cluster)
resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  identifier         = "dbt-data-vault-aurora-instance"
  instance_class     = "db.serverless"
  engine             = "aurora-postgresql"
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  tags = {
    Name = "dbt-data-vault-aurora-instance"
  }
}

# Aurora Subnet Group (Required for Multi-AZ)
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "dbt-data-vault-aurora-subnet-group"
  }
}

# Generate a random password for the Aurora DB
resource "random_password" "aurora_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Secret with the Aurora endpoint and credentials
resource "aws_secretsmanager_secret" "aurora_secret" {
  name = "dbt-data-vault-aurora-secret"
}

resource "aws_secretsmanager_secret_version" "aurora_secret_version" {
  secret_id     = aws_secretsmanager_secret.aurora_secret.id
  secret_string = jsonencode({
    host     = aws_rds_cluster.aurora_cluster.endpoint
    port     = 5432
    dbname   = aws_rds_cluster.aurora_cluster.database_name
    username = aws_rds_cluster.aurora_cluster.master_username
    password = random_password.aurora_password.result
  })
}