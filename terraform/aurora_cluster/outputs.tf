output "aurora_cluster" {
  value = aws_rds_cluster.aurora_cluster
}

output "aurora_credentials_secret_arn" {
  value = aws_secretsmanager_secret.aurora_secret.arn
}