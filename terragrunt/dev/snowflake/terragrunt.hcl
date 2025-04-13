include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "snowflake_provider" {
  path = find_in_parent_folders("snowflake_provider.hcl")
}

dependency "aws" {
  config_path = find_in_parent_folders("aws")
}

terraform {
  source = "${get_repo_root()}/terraform//snowflake"
}

inputs =  {
  stage = "DEV"
  snowflake_integration_iam_role = dependency.aws.outputs.snowflake_integration_iam_role
}
