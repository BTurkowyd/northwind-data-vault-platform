SELECT
    *,
    '{{ var("record_source") }}.territories' as record_source
FROM northwind_iceberg_dev.territories