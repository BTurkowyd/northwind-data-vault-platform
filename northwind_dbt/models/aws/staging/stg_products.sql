SELECT
    *,
    '{{ var("record_source") }}.products' AS record_source
FROM northwind_iceberg_dev.products
