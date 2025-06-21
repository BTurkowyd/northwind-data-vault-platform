-- This staging model extracts all columns from the source 'order_details' table and adds a record_source column.

SELECT
    *,
    '{{ var("record_source") }}.order_details' AS record_source
FROM northwind_iceberg_dev.order_details
