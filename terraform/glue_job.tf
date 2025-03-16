module "glue_job" {
  source = "./glue_job"
  aurora_cluster = aws_rds_cluster.aurora_cluster
  aurora_sg = aws_security_group.aurora_sg
  stage = var.stage
  subnet = aws_subnet.subnet1
  bucket = aws_s3_bucket.bucket
}