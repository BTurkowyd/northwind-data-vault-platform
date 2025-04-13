
resource "snowflake_account_role" "northwind_owner" {
  name    = "NORTHWIND_OWNER_${var.stage}"
  comment = "Role to manage NORTHWIND_DB"
}

resource "snowflake_grant_privileges_to_account_role" "grant_ownership_db" {
  account_role_name = snowflake_account_role.northwind_owner.name
  all_privileges    = true
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.my_db.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "example" {
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

resource "snowflake_grant_privileges_to_account_role" "grant_wh_access" {
  privileges        = ["USAGE", "OPERATE", "MONITOR"]
  account_role_name = snowflake_account_role.northwind_owner.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.northwind_wh.name
  }
}
