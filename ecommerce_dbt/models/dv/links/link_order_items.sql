{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_order_item_key'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hp.hub_product_key']) }} AS link_order_item_key,
    ho.hub_order_key,
    hp.hub_product_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM source_data sd
JOIN hub_orders ho ON sd.order_id = ho.order_id
JOIN hub_products hp ON sd.product_id = hp.product_id

{% if is_incremental() %}
WHERE item_id NOT IN (SELECT item_id FROM {{ this }})
{% endif %}