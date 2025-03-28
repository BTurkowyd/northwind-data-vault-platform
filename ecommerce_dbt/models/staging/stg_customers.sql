{{ config(materialized='view') }}

SELECT
    customer_id,
    name,
    email,
    CAST(created_at AS timestamp) AS created_at,
    '{{ var("record_source") }}.customers' as record_source
FROM ecommerce_db_dev.customers