{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    partitioned_by=['month(created_at)'],
    unique_key='order_id',
    incremental_strategy='merge',
    merge_update_columns=['customer_id', 'total_amount', 'status', 'created_at']
) }}

SELECT
    order_id,
    customer_id,
    total_amount,
    status,
    created_at
FROM ecommerce_db_dev.orders
