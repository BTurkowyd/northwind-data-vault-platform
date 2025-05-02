SELECT
    *,
    '{{ var("record_source") }}.employees' AS record_source
FROM northwind_iceberg_dev.employees
