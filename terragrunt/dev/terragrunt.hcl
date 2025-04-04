include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_repo_root()}/terraform"
}

inputs =  {
  stage = "${basename(get_terragrunt_dir())}"
  aws_account_id = "926728314305"
}
