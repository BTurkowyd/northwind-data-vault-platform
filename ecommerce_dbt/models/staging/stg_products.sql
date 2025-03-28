{{ config(materialized='view') }}

SELECT
    product_id,
    name,
    category,
    price,
    CAST(created_at AS timestamp) AS created_at,
    '{{ var("record_source") }}.products' as record_source
FROM ecommerce_db_dev.products