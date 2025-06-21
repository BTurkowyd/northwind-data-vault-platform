-- This staging model extracts all columns from the source 'shippers' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.shippers' AS record_source
FROM northwind_iceberg_dev.shippers
