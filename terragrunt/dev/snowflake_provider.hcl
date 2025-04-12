locals {
  snowflake_org        = get_env("SNOWFLAKE_ORGANIZATION_NAME", "")
  snowflake_account    = get_env("SNOWFLAKE_ACCOUNT_NAME", "")
  snowflake_user       = get_env("SNOWFLAKE_USER", "")
  snowflake_role       = get_env("SNOWFLAKE_ROLE", "")
  snowflake_privatekey = get_env("SNOWFLAKE_PRIVATE_KEY", "")
}

generate "snowflake_provider" {
  path      = "snowflake_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOT
    provider "snowflake" {
      organization_name = "${local.snowflake_org}"
      account_name      = "${local.snowflake_account}"
      user              = "${local.snowflake_user}"
      role              = "${local.snowflake_role}"
      authenticator     = "SNOWFLAKE_JWT"
      private_key       = file("${local.snowflake_privatekey}")
    }
  EOT
}
