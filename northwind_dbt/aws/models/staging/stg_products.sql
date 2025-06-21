-- This staging model extracts all columns from the source 'products' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.products' AS record_source
FROM northwind_iceberg_dev.products
