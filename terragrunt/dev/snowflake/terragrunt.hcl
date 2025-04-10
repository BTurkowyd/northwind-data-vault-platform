include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "snowflake_provider" {
  path = find_in_parent_folders("snowflake_provider.hcl")
}


terraform {
  source = "${get_repo_root()}/terraform//snowflake"
}

inputs =  {
  stage = "dev"
}
