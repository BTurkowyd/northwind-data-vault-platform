SELECT
    *,
    '{{ var("record_source") }}.employee_territories' as record_source
FROM northwind_iceberg_dev.employee_territories
