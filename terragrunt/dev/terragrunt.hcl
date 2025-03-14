include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_repo_root()}/terraform"
}

inputs =  {
  stage = "${basename(get_terragrunt_dir())}"
}