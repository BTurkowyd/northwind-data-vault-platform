-- This staging model extracts all columns from the source 'orders' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.orders' AS record_source
FROM northwind_iceberg_dev.orders
