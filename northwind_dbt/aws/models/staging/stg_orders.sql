SELECT
    *,
    '{{ var("record_source") }}.orders' AS record_source
FROM northwind_iceberg_dev.orders
