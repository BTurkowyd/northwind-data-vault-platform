SELECT
    *,
    '{{ var("record_source") }}.territories' AS record_source
FROM northwind_iceberg_dev.territories
