{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_item_key',
    merge_update_columns=['hashdiff', 'load_ts', 'quantity', 'price']
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
),
-- The link_order_items CTE is a reference to the link_order_items model
link_order_items AS (
    SELECT hub_order_key, hub_product_key, link_order_item_key
    FROM {{ ref('link_order_items') }}
),
-- The prepared CTE joins the source_data, hub_orders, hub_products, and link_order_items CTEs
prepared AS (
    SELECT
        sd.*,
        lo.link_order_item_key,
        {{ dbt_utils.generate_surrogate_key(['sd.quantity', 'sd.price']) }} AS hashdiff
    FROM source_data sd
    -- The JOIN clause links the source_data and hub_orders CTEs on the order_id column
    JOIN hub_orders ho ON sd.order_id = ho.order_id
    -- The JOIN clause links the source_data and hub_products CTEs on the product_id column
    JOIN hub_products hp ON sd.product_id = hp.product_id
    -- The JOIN clause links the hub_orders and hub_products CTEs on the hub_order_key and hub_product_key columns
    JOIN link_order_items lo
        ON ho.hub_order_key = lo.hub_order_key
       AND hp.hub_product_key = lo.hub_product_key
)
-- The final SELECT statement generates the surrogate key for the satellite table
SELECT
    {{ dbt_utils.generate_surrogate_key(['link_order_item_key', 'hashdiff']) }} AS sat_order_item_key,
    link_order_item_key,
    quantity,
    price,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}