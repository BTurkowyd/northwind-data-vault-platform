{{ config(materialized='view') }}

SELECT
    item_id,
    order_id,
    product_id,
    quantity,
    price,
    '{{ var("record_source") }}.order_items' as record_source
FROM ecommerce_db_dev.order_items