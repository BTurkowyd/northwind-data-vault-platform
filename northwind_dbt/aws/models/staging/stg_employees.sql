-- This staging model extracts all columns from the source 'employees' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.employees' AS record_source
FROM northwind_iceberg_dev.employees
