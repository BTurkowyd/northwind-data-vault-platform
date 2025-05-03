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
}

# resource "snowflake_masking_policy" "redact_varchar_pii" {
#   name     = "REDACT_VARCHAR_PII"
#   database = snowflake_database.my_db.name
#   schema   = snowflake_schema.northwind_schema.name
#   depends_on = [snowflake_tag.pii]
#
#   argument {
#     name = "input_val"
#     type = "VARCHAR"
#   }
#
#   body = <<-SQL
#     CASE
#       WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
#       ELSE 'REDACTED'
#     END
#   SQL
#
#   return_data_type = "VARCHAR"
# }
#
# resource "snowflake_masking_policy" "redact_number_pii" {
#   name     = "REDACT_NUMBER_PII"
#   database = snowflake_database.my_db.name
#   schema   = snowflake_schema.northwind_schema.name
#   depends_on = [snowflake_tag.pii]
#
#   argument {
#     name = "input_val"
#     type = "NUMBER"
#   }
#
#   body = <<-SQL
#     CASE
#       WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
#       ELSE -1
#     END
#   SQL
#
#   return_data_type = "NUMBER"
# }
#
# resource "snowflake_masking_policy" "redact_varchar_sensitivity" {
#   name     = "REDACT_VARCHAR_SENSITIVITY"
#   database = snowflake_database.my_db.name
#   schema   = snowflake_schema.northwind_schema.name
#   depends_on = [snowflake_tag.sensitivity]
#
#   argument {
#     name = "input_val"
#     type = "VARCHAR"
#   }
#
#   body = <<-SQL
#     CASE
#       WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
#       ELSE 'REDACTED'
#     END
#   SQL
#
#   return_data_type = "VARCHAR"
# }
#
# resource "snowflake_masking_policy" "redact_number_sensitivity" {
#   name     = "REDACT_NUMBER_SENSITIVITY"
#   database = snowflake_database.my_db.name
#   schema   = snowflake_schema.northwind_schema.name
#   depends_on = [snowflake_tag.sensitivity]
#
#   argument {
#     name = "input_val"
#     type = "NUMBER"
#   }
#
#   body = <<-SQL
#     CASE
#       WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN input_val
#       ELSE -1
#     END
#   SQL
#
#   return_data_type = "NUMBER"
# }
