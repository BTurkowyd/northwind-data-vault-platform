{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_order_key'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['order_id', 'customer_id']) }} AS link_order_key,
    order_id,
    customer_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM {{ ref('stg_orders') }}

{% if is_incremental() %}
WHERE order_id NOT IN (SELECT order_id FROM {{ this }})
{% endif %}