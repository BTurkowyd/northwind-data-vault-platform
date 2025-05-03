resource "snowflake_tag" "pii" {
  name           = "pii"
  database       = snowflake_database.my_db.name
  schema         = snowflake_schema.northwind_schema.name
  comment        = "PII tag"
  allowed_values = ["true", "false"]
}

resource "snowflake_tag" "sensitivity" {
  name           = "sensitivity"
  database       = snowflake_database.my_db.name
  schema         = snowflake_schema.northwind_schema.name
  comment        = "Sensitivity tag"
  allowed_values = ["low", "high", "critical"]
  masking_policies = [
    snowflake_masking_policy.redact_varchar_sensitivity.fully_qualified_name,
    snowflake_masking_policy.redact_number_sensitivity.fully_qualified_name
  ]
}

resource "snowflake_masking_policy" "redact_varchar_sensitivity" {
  name     = "REDACT_VARCHAR_SENSITIVITY"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "VARCHAR"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.critical_sensitivity_role.name}') THEN input_val
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.high_sensitivity_role.name}') THEN 'REDACTED_HIGH'
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.low_sensitivity_role.name}') THEN 'REDACTED_LOW'
      ELSE 'REDACTED'
    END
  SQL

  return_data_type = "VARCHAR"
}

resource "snowflake_masking_policy" "redact_number_sensitivity" {
  name     = "REDACT_NUMBER_SENSITIVITY"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "NUMBER"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.critical_sensitivity_role.name}') THEN input_val
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.high_sensitivity_role.name}') THEN -3
      WHEN IS_ROLE_IN_SESSION('${snowflake_account_role.low_sensitivity_role.name}') THEN -2
      ELSE -1
    END
  SQL

  return_data_type = "NUMBER"
}
