SELECT
    *,
    '{{ var("record_source") }}.categories' AS record_source
FROM northwind_iceberg_dev.categories
