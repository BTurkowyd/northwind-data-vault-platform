SELECT
    *,
    '{{ var("record_source") }}.customers' AS record_source
FROM northwind_iceberg_dev.customers
