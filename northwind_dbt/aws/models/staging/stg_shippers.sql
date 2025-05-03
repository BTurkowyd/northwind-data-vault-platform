SELECT
    *,
    '{{ var("record_source") }}.shippers' AS record_source
FROM northwind_iceberg_dev.shippers
