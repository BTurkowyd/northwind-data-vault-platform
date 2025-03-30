SELECT
    *,
    '{{ var("record_source") }}.categories' as record_source
FROM northwind_iceberg_dev.categories