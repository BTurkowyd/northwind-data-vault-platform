SELECT
    *,
    '{{ var("record_source") }}.region' AS record_source
FROM northwind_iceberg_dev.region
