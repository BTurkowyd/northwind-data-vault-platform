# Main role for Northwind database access
resource "snowflake_account_role" "northwind_role" {
  name    = "NORTHWIND_ROLE_${upper(var.stage)}"
  comment = "A role to use for the Northwind database"
}

# Roles for different sensitivity levels (used for masking policies)
resource "snowflake_account_role" "low_sensitivity_role" {
  name    = "LOW_SENSITIVITY_ROLE_${upper(var.stage)}"
  comment = "A role to use for low sensitivity data"
}

resource "snowflake_account_role" "high_sensitivity_role" {
  name    = "HIGH_SENSITIVITY_ROLE_${upper(var.stage)}"
  comment = "A role to use for high sensitivity data"
}

resource "snowflake_account_role" "critical_sensitivity_role" {
  name    = "CRITICAL_SENSITIVITY_ROLE_${upper(var.stage)}"
  comment = "A role to use for critical sensitivity data"
}

# Grant the Northwind role to a parent role (e.g., for automation or admin)
resource "snowflake_grant_account_role" "grant_northwind_role" {
  role_name        = snowflake_account_role.northwind_role.name
  parent_role_name = "TERRAGRUNT_ROLE"
}

# Grant warehouse usage privileges to the Northwind role
resource "snowflake_grant_privileges_to_account_role" "grant_wh_access" {
  privileges        = ["USAGE", "OPERATE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.northwind_wh.name
  }
}

# Grant database usage privileges to the Northwind role
resource "snowflake_grant_privileges_to_account_role" "grant_db_access" {
  privileges        = ["USAGE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.my_db.name
  }
}

# Grant schema usage privileges to the Northwind role for a specific schema
resource "snowflake_grant_privileges_to_account_role" "grant_schema_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema {
    schema_name = snowflake_schema.northwind_schema.fully_qualified_name
  }
}

# Grant schema privileges (modify, create table, usage) for all schemas in the database
resource "snowflake_grant_privileges_to_account_role" "grant_schema_access" {
  privileges        = ["MODIFY", "CREATE TABLE", "USAGE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema {
    all_schemas_in_database = snowflake_database.my_db.name
  }
}

# Grant table privileges (select, insert, update) for all tables in the schema
resource "snowflake_grant_privileges_to_account_role" "grant_table_access" {
  privileges        = ["SELECT", "INSERT", "UPDATE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.northwind_schema.fully_qualified_name
    }
  }
}

# Grant future table privileges (select, insert, update) for all future tables in the schema
resource "snowflake_grant_privileges_to_account_role" "grant_future_table_access" {
  privileges        = ["SELECT", "INSERT", "UPDATE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.northwind_schema.fully_qualified_name
    }
  }
}
