SELECT
    *,
    '{{ var("record_source") }}.suppliers' as record_source
FROM northwind_iceberg_dev.suppliers