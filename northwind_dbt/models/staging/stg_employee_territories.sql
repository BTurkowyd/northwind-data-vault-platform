SELECT
    *,
    '{{ var("record_source") }}.employee_territories' AS record_source
FROM northwind_iceberg_dev.employee_territories
