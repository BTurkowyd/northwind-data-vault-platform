locals {
  region = "eu-central-1"
  bucket = "terraform-states-6mabw3s4smjiozsqyi76rq"
  key = "terraform/dbt-data-vault/${path_relative_to_include()}/terraform.tfstate"
  profile = "cdk-dev"
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
