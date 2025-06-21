-- This staging model extracts all columns from the source 'customers' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.customers' AS record_source
FROM northwind_iceberg_dev.customers
