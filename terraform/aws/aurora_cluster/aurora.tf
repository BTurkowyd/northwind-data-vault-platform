# Aurora Serverless PostgreSQL Cluster definition
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "${var.name}-aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = "16.3"
  enable_http_endpoint   = true
  database_name          = var.database_name
  master_username        = "master"
  master_password        = var.aurora_password.result
  storage_encrypted      = true
  skip_final_snapshot    = true
  network_type           = "IPV4"
  vpc_security_group_ids = var.sg_ids
  db_subnet_group_name   = var.db_subnet_group_name

  # Serverless v2 scaling configuration
  serverlessv2_scaling_configuration {
    min_capacity             = var.min_capacity
    max_capacity             = var.max_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
  }

  tags = {
    Name = "${var.name}-aurora-cluster"
  }
}

# Aurora DB Instance (required for the cluster to be operational)
resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  identifier         = "${var.name}-aurora-instance"
  instance_class     = "db.serverless"
  engine             = "aurora-postgresql"
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  tags = {
    Name = "${var.name}-aurora-instance"
  }
}
