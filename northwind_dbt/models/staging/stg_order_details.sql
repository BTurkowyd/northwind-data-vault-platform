SELECT
    *,
    '{{ var("record_source") }}.order_details' AS record_source
FROM northwind_iceberg_dev.order_details
