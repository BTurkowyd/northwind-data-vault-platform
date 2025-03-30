SELECT
    *,
    '{{ var("record_source") }}.customers' as record_source
FROM northwind_iceberg_dev.customers