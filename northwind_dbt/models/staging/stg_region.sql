SELECT
    *,
    '{{ var("record_source") }}.region' as record_source
FROM northwind_iceberg_dev.region