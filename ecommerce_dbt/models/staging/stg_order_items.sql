{{ config(materialized='view') }}

SELECT
    item_id,
    order_id,
    product_id,
    quantity,
    price
FROM ecommerce_db_dev.order_items