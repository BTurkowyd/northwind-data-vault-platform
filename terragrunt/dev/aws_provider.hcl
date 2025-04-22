locals {
  region = "eu-central-1"
  bucket = "terraform-states-6mabw3s4smjiozsqyi76rq"
  key = "terraform/dbt-data-vault/${path_relative_to_include()}/terraform.tfstate"
  profile = get_env("AWS_PROFILE", "")
  repo_name = "northwind-data-vault-platform"
}

inputs = {
  repo_name = local.repo_name
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
    contents = <<-EOT
      provider "aws" {
        region = "${local.region}"
        %{ if local.profile != "" }
        profile = "${local.profile}"
        %{ endif }
       default_tags {
         tags = {
           repo_name = "${local.repo_name}"
         }
       }
      }
  EOT
}
