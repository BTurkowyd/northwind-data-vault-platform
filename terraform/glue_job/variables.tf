variable "stage" {
  description = "The stage of the environment"
}

variable "aurora_cluster" {
  description = "The Aurora cluster"
}

variable "subnet" {
  description = "The subnet to use for the Glue connection"
}

variable "bucket" {
  description = "The S3 bucket to store the Glue scripts"
}

variable "raw_data_directory" {
    description = "The directory in the S3 bucket where the raw data is stored"
}

variable "aurora_credentials_secret_arn" {
    description = "The secret containing the Aurora credentials"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  default = "926728314305"
}

variable "glue_sg" {
  description = "The security group for the Glue job"
}

variable "debug" {
    description = "Enable debug mode"
    default = "false"
}