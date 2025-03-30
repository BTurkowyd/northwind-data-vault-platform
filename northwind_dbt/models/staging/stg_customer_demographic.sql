SELECT
    *,
    '{{ var("record_source") }}.customer_demographic' as record_source
FROM northwind_iceberg_dev.customer_demographics