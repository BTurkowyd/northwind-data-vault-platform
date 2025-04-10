resource "snowflake_database" "my_db" {
  name    = "NORTHWIND_DB"
  comment = "Northwind database created with Terraform"
}
