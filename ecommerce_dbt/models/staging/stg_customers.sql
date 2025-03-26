{{ config(materialized='view') }}

SELECT
    customer_id,
    name,
    email,
    CAST(created_at AS timestamp) AS created_at
FROM ecommerce_db_dev.customers