SELECT
    *,
    '{{ var("record_source") }}.customer_customer_demo' as record_source
FROM northwind_iceberg_dev.customer_customer_demo