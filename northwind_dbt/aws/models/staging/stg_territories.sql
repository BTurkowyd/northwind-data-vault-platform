-- This staging model extracts all columns from the source 'territories' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.territories' AS record_source
FROM northwind_iceberg_dev.territories
