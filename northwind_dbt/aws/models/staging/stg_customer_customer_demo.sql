-- This staging model extracts all columns from the source 'customer_customer_demo' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.customer_customer_demo' AS record_source
FROM northwind_iceberg_dev.customer_customer_demo
