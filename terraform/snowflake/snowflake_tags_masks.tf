resource "snowflake_tag" "pii" {
  name           = "pii"
  database       = snowflake_database.my_db.name
  schema         = snowflake_schema.northwind_schema.name
  comment        = "PII tag"
  allowed_values = ["true", "false"]
  masking_policies = [
    snowflake_masking_policy.redact_varchar.fully_qualified_name,
    snowflake_masking_policy.redact_number.fully_qualified_name
  ]
}

resource "snowflake_tag" "sensitivity" {
  name           = "sensitivity"
  database       = snowflake_database.my_db.name
  schema         = snowflake_schema.northwind_schema.name
  comment        = "Sensitivity tag"
  allowed_values = ["low", "high", "critical"]
  masking_policies = [
    snowflake_masking_policy.redact_varchar.fully_qualified_name,
    snowflake_masking_policy.redact_number.fully_qualified_name
  ]
}

resource "snowflake_masking_policy" "redact_varchar" {
  name     = "REDACT_VARCHAR"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "VARCHAR"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      ELSE 'REDACTED'
    END
  SQL

  return_data_type = "VARCHAR"
}

resource "snowflake_masking_policy" "redact_number" {
  name     = "REDACT_NUMBER"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "NUMBER"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      ELSE -1
    END
  SQL

  return_data_type = "NUMBER"
}
