SELECT
    *,
    '{{ var("record_source") }}.shippers' as record_source
FROM northwind_iceberg_dev.shippers