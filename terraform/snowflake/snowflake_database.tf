resource "snowflake_database" "my_db" {
  name    = "NORTHWIND_DB"
  comment = "Northwind database created with Terraform"
}

resource "snowflake_schema" "northwind_schema" {
  name     = "NORTHWIND_SCHEMA"
  database = snowflake_database.my_db.name
  comment  = "Northwind schema created with Terraform"
}
