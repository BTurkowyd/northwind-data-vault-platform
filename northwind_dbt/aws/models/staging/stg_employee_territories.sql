-- This staging model extracts all columns from the source 'employee_territories' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.employee_territories' AS record_source
FROM northwind_iceberg_dev.employee_territories
