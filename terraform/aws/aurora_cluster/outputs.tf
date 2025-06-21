# Output the Aurora cluster resource for use in parent modules
output "aurora_cluster" {
  value = aws_rds_cluster.aurora_cluster
}

# Output the ARN of the Aurora credentials secret for use in other modules (e.g., Glue jobs)
output "aurora_credentials_secret_arn" {
  value = aws_secretsmanager_secret.aurora_secret.arn
}
