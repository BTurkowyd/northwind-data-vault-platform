-- This staging model extracts all columns from the source 'categories' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.categories' AS record_source
FROM northwind_iceberg_dev.categories
