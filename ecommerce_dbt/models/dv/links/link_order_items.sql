{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_order_item_key'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['item_id', 'order_id']) }} AS link_order_item_key,
    item_id,
    order_id,
    product_id,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM {{ ref('stg_order_items') }}

{% if is_incremental() %}
WHERE item_id NOT IN (SELECT item_id FROM {{ this }})
{% endif %}