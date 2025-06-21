-- This staging model extracts all columns from the source 'us_states' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.us_states' AS record_source
FROM northwind_iceberg_dev.us_states
