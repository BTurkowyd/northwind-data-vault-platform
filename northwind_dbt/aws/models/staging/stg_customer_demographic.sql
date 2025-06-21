-- This staging model extracts all columns from the source 'customer_demographics' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.customer_demographic' AS record_source
FROM northwind_iceberg_dev.customer_demographics
