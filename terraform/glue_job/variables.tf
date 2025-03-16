variable "stage" {
  description = "The stage of the environment"
}

variable "aurora_cluster" {
  description = "The Aurora cluster"
}

variable "aurora_sg" {
  description = "The security group for the Aurora cluster"
}

variable "subnet" {
  description = "The subnet to use for the Glue connection"
}

variable "bucket" {
  description = "The S3 bucket to store the Glue scripts"
}