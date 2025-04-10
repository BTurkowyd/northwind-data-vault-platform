locals {
  region = "eu-central-1"
  bucket = "terraform-states-6mabw3s4smjiozsqyi76rq"
  key = "terraform/dbt-data-vault/${path_relative_to_include()}/terraform.tfstate"
  profile = "cdk-dev"
}

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<-EOT
    terraform {
      required_version = "1.9.0"
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = ">= 5.91.0"
        }
        snowflake = {
          source  = "Snowflake-Labs/snowflake"
          version = "1.0.5"
        }
      }
    }
  EOT
}

generate "backend" {
  path = "backend.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<-EOT
terraform {
  backend "s3" {
    bucket = "${local.bucket}"
    key    = "${local.key}"
    region = "${local.region}"
  }
}
  EOT
}
