-- This staging model extracts all columns from the source 'region' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.region' AS record_source
FROM northwind_iceberg_dev.region
