include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "aws_provider" {
  path = find_in_parent_folders("aws_provider.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform//aws"
}

inputs =  {
  stage = "dev"
  aws_account_id = "926728314305"
  snowflake_external_id = get_env("SNOWFLAKE_EXTERNAL_ID")
  snowflake_account_arn = get_env("SNOWFLAKE_ACCOUNT_ARN")
}
