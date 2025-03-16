resource "aws_glue_catalog_database" "glue_db" {
  name = "ecommerce_db_${var.stage}"

  tags = {
    Name = "Glue Iceberg Database for ecommerce"
  }
}

resource "aws_glue_connection" "glue_rds_connection" {
  name = "ecommerce-aurora-postgres-connection-${var.stage}"

  connection_properties = {
    "JDBC_CONNECTION_URL" = "jdbc:postgresql://${var.aurora_cluster.endpoint}:5432/ecommerce_db"
    "USERNAME"            = var.aurora_cluster.master_username
    "PASSWORD"            = var.aurora_cluster.master_password
  }

  physical_connection_requirements {
    availability_zone      = "eu-central-1a"
    security_group_id_list = [var.aurora_sg.id]
    subnet_id             = var.subnet.id
  }
}

resource "aws_glue_job" "glue_etl_job" {
  name     = "ecommerce-aurora-to-s3-etl-${var.stage}"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${var.bucket.bucket}/scripts/glue_etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"                 = "s3://${var.bucket.bucket}/temp"
    "--job-language"            = "python"
    "--enable-glue-datacatalog" = "true"
  }

  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2
}

# s3 object with the glue python script
resource "aws_s3_object" "glue_etl_script" {
  bucket = var.bucket.bucket
  key    = "scripts/glue_etl.py"
  source = "${path.module}/src/glue_etl.py"
}