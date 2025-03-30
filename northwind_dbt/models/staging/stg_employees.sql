SELECT
    *,
    '{{ var("record_source") }}.employees' as record_source
FROM northwind_iceberg_dev.employees