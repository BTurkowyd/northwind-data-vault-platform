{{ config(materialized='view') }}

SELECT
    order_id,
    customer_id,
    total_amount,
    status,
    CAST(created_at AS timestamp) AS created_at,
    '{{ var("record_source") }}.orders' as record_source
FROM ecommerce_db_dev.orders