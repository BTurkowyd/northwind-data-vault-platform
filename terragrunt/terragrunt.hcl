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
      }
    }
  EOT
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
    contents = <<-EOT
      provider "aws" {
        region = "${local.region}"
        profile = "${local.profile}"
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
