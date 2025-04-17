resource "aws_glue_catalog_database" "glue_db" {
  name = "${var.raw_data_directory}_${var.stage}"

  tags = {
    Name = "Glue Iceberg Database for ${var.raw_data_directory} in ${var.stage}"
  }
}

resource "aws_glue_connection" "glue_rds_connection" {
  name = "${replace(var.raw_data_directory, "_", "-")}-postgres-connection-${var.stage}"

  connection_properties = {
    "JDBC_CONNECTION_URL" = "jdbc:postgresql://${var.aurora_cluster.endpoint}:5432/${var.aurora_cluster.database_name}"
    "USERNAME"            = var.aurora_cluster.master_username
    "PASSWORD"            = var.aurora_cluster.master_password
  }

  physical_connection_requirements {
    availability_zone      = var.subnet.availability_zone
    security_group_id_list = [var.glue_sg.id]
    subnet_id              = var.subnet.id
  }
}

resource "aws_glue_job" "glue_etl_job" {
  name     = "${replace(var.raw_data_directory, "_", "-")}-aurora-to-s3-etl-${var.stage}"
  role_arn = aws_iam_role.glue_role.arn
  timeout  = 30

  connections = [aws_glue_connection.glue_rds_connection.name]

  command {
    script_location = "s3://${var.bucket.bucket}/scripts/${var.raw_data_directory}_etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"                          = "s3://${var.bucket.bucket}/temp"
    "--job-language"                     = "python"
    "--extra-py-files"                   = "s3://${aws_s3_object.python_modules.bucket}/${aws_s3_object.python_modules.key}"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--disable-proxy-v2"                 = "true"
    "--region"                           = "eu-central-1"
    "--AURORA_CREDS_SECRET"              = var.aurora_credentials_secret_arn
    "--DESTINATION_BUCKET"               = var.bucket.id
    "--DESTINATION_DIRECTORY"            = var.raw_data_directory
    "--GLUE_DATABASE"                    = aws_glue_catalog_database.glue_db.name
    "--datalake-formats"                 = "iceberg"
    "--DEBUG"                            = var.debug
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
}

# s3 object with the glue python script
resource "aws_s3_object" "glue_etl_script" {
  bucket = var.bucket.bucket
  key    = "scripts/${var.raw_data_directory}_etl.py"
  source = "${path.module}/src/glue_etl.py"
  etag   = filemd5("${path.module}/src/glue_etl.py")
}

data "archive_file" "python_modules" {
  type        = "zip"
  output_path = "${path.module}/build/python_modules.zip"
  source_dir  = "${path.module}/src"
  excludes    = ["*.pyc", "*.pyo", "__pycache__", "glue_etl.py"]
}

resource "aws_s3_object" "python_modules" {
  bucket = var.bucket.bucket
  key    = "scripts/python_modules.zip"
  source = data.archive_file.python_modules.output_path
  etag   = filemd5(data.archive_file.python_modules.output_path)
}
