resource "snowflake_warehouse" "northwind_wh" {
  name                = "NORTHWIND_WH_${var.stage}"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  comment             = "Warehouse for NORTHWIND DB operations"
}
