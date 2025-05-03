resource "snowflake_tag" "pii" {
  name           = "pii"
  database       = snowflake_database.my_db.name
  schema         = snowflake_schema.northwind_schema.name
  comment        = "PII tag"
  allowed_values = ["true", "false"]
  masking_policies = [
    snowflake_masking_policy.redact_varchar_pii.fully_qualified_name,
    snowflake_masking_policy.redact_number_pii.fully_qualified_name
  ]
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

resource "snowflake_masking_policy" "redact_varchar_pii" {
  name     = "REDACT_VARCHAR_PII"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "VARCHAR"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('pii') = 'true' THEN 'REDACTED'
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('pii') = 'false' THEN input_val
    END
  SQL

  return_data_type = "VARCHAR"
}

resource "snowflake_masking_policy" "redact_number_pii" {
  name     = "REDACT_NUMBER_PII"
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.northwind_schema.name

  argument {
    name = "input_val"
    type = "NUMBER"
  }

  body = <<-SQL
    CASE
      WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('pii') = 'true' THEN -1
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('pii') = 'false' THEN input_val
    END
  SQL

  return_data_type = "NUMBER"
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
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'critical' THEN 'CRITICAL_SENSITIVITY'
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'high' THEN 'HIGH SENSITIVITY'
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'low' THEN input_val
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
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'critical' THEN -1
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'high' THEN -2
      WHEN SYSTEM$GET_TAG_ON_CURRENT_COLUMN('sensitivity') = 'low' THEN input_val
    END
  SQL

  return_data_type = "NUMBER"
}
