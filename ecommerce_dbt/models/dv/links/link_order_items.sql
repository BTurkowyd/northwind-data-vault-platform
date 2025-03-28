{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_order_item_key'
) }}

-- The source_data CTE is a reference to the stg_order_items model
WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),
-- The hub_orders CTE is a reference to the hub_orders model
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
-- The hub_products CTE is a reference to the hub_products model
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
)
-- The final SELECT statement generates the surrogate key for the link table
SELECT
    {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hp.hub_product_key']) }} AS link_order_item_key,
    ho.hub_order_key,
    hp.hub_product_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM source_data sd
-- The JOIN clause links the source_data and hub_orders CTEs on the order_id column
JOIN hub_orders ho ON sd.order_id = ho.order_id
-- The JOIN clause links the source_data and hub_products CTEs on the product_id column
JOIN hub_products hp ON sd.product_id = hp.product_id

{% if is_incremental() %}
WHERE item_id NOT IN (SELECT item_id FROM {{ this }})
{% endif %}