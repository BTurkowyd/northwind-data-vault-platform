resource "aws_secretsmanager_secret" "aurora_secret" {
  name = "${var.name}-aurora-secret"
}

resource "aws_secretsmanager_secret_version" "aurora_secret_version" {
  secret_id = aws_secretsmanager_secret.aurora_secret.id
  secret_string = jsonencode({
    host     = aws_rds_cluster.aurora_cluster.endpoint
    port     = 5432
    dbname   = aws_rds_cluster.aurora_cluster.database_name
    username = aws_rds_cluster.aurora_cluster.master_username
    password = var.aurora_password.result
  })
}
