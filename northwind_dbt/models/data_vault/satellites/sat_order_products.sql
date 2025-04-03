{{ config(
    unique_key='sat_order_product_key',
    merge_update_columns=['unit_price', 'quantity', 'discount', 'hashdiff', 'load_ts', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_details') }}
),
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
),
link_order_products AS (
    SELECT hub_order_key, hub_product_key, link_order_product_key
    FROM {{ ref('link_order_products') }}
),
prepared AS (
    SELECT
        sd.*,
        lop.link_order_product_key,
        {{ dbt_utils.generate_surrogate_key(['sd.unit_price', 'sd.quantity', 'sd.discount']) }} AS hashdiff
    FROM source_data sd
    JOIN hub_orders ho ON sd.order_id = ho.order_id
    JOIN hub_products hp ON sd.product_id = hp.product_id
    JOIN link_order_products lop
        ON ho.hub_order_key = lop.hub_order_key
       AND hp.hub_product_key = lop.hub_product_key
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['link_order_product_key', 'hashdiff']) }} AS sat_order_product_key,
    link_order_product_key,
    unit_price,
    quantity,
    discount,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
