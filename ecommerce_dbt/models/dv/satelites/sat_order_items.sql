{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_item_key',
    merge_update_columns=['hashdiff', 'load_ts', 'quantity', 'price']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
),
prepared AS (
    SELECT
        sd.*,
        ho.hub_order_key,
        hp.hub_product_key,
        {{ dbt_utils.generate_surrogate_key(['sd.quantity', 'sd.price']) }} AS hashdiff
    FROM source_data sd
    JOIN hub_orders ho ON sd.order_id = ho.order_id
    JOIN hub_products hp ON sd.product_id = hp.product_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'hub_order_key',
        'hub_product_key',
        'hashdiff'
    ]) }} AS sat_order_item_key,

    hub_order_key,
    hub_product_key,
    quantity,
    price,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts

FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}