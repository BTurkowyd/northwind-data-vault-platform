SELECT
    *,
    '{{ var("record_source") }}.products' as record_source
FROM northwind_iceberg_dev.products