{{ config(materialized='view') }}

SELECT
    order_id,
    customer_id,
    total_amount,
    status,
    CAST(created_at AS timestamp) AS created_at
FROM ecommerce_db_dev.orders