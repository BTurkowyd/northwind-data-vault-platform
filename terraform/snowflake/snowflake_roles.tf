resource "snowflake_account_role" "northwind_role" {
  name    = "NORTHWIND_ROLE_${upper(var.stage)}"
  comment = "A role to use for the Northwind database"
}

resource "snowflake_grant_account_role" "grant_northwind_role" {
  role_name        = snowflake_account_role.northwind_role.name
  parent_role_name = "TERRAGRUNT_ROLE"
}

# Grant warehouse usage to the role
resource "snowflake_grant_privileges_to_account_role" "grant_wh_access" {
  privileges        = ["USAGE", "OPERATE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.northwind_wh.name
  }
}

# Grant database usage to the role
resource "snowflake_grant_privileges_to_account_role" "grant_db_access" {
  privileges        = ["USAGE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.my_db.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_schema_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema {
    schema_name = snowflake_schema.northwind_schema.fully_qualified_name
  }
}

# Grant schema usage to the role
resource "snowflake_grant_privileges_to_account_role" "grant_schema_access" {
  privileges        = ["MODIFY", "CREATE TABLE", "USAGE"]
  account_role_name = snowflake_account_role.northwind_role.name
  on_schema {
    all_schemas_in_database = snowflake_database.my_db.name
  }
}

# Grant table usage to the role
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

# Grant future table usage to the role
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
