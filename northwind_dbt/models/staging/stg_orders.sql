SELECT
    *,
    '{{ var("record_source") }}.orders' as record_source
FROM northwind_iceberg_dev.orders