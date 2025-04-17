
resource "snowflake_account_role" "northwind_owner" {
  name    = "NORTHWIND_OWNER_${var.stage}"
  comment = "Role to manage NORTHWIND_DB"
}

# Grant ownership of the database to the account role
resource "snowflake_grant_privileges_to_account_role" "grant_ownership_db" {
  account_role_name = snowflake_account_role.northwind_owner.name
  all_privileges    = true
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.my_db.name
  }
}

# Grant ownership of the schema to the account role
resource "snowflake_grant_privileges_to_account_role" "grant_ownership_schema" {
  account_role_name = snowflake_account_role.northwind_owner.name
  on_schema {
    schema_name = snowflake_schema.northwind_schema.fully_qualified_name
  }
  all_privileges = true
}

resource "snowflake_grant_account_role" "parent_role_grant" {
  role_name        = snowflake_account_role.northwind_owner.name
  parent_role_name = "ACCOUNTADMIN"
}

# Grant usage on the warehouse to the account role
resource "snowflake_grant_privileges_to_account_role" "grant_wh_access" {
  privileges        = ["USAGE", "OPERATE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_owner.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.northwind_wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_northwind_db_access" {
  privileges        = ["SELECT", "INSERT", "UPDATE"]
  account_role_name = snowflake_account_role.northwind_owner.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.my_db.name
    }
  }
}
