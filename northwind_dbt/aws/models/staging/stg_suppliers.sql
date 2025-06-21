-- This staging model extracts all columns from the source 'suppliers' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.suppliers' AS record_source
FROM northwind_iceberg_dev.suppliers
