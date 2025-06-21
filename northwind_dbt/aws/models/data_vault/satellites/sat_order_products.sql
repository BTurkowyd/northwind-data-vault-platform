-- This satellite table captures the attributes of order-product relationships in the Northwind database.
{{ config(
    unique_key='sat_order_product_key',
    merge_update_columns=['unit_price', 'quantity', 'discount', 'hashdiff', 'load_ts', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_order_details'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_details') }}
),

-- The hub tables for orders and products, and the link table for order-products, are referenced to get the keys.
hub_orders AS (
    SELECT
        order_id,
        hub_order_key
    FROM {{ ref('hub_orders') }}
),

hub_products AS (
    SELECT
        product_id,
        hub_product_key
    FROM {{ ref('hub_products') }}
),

link_order_products AS (
    SELECT
        hub_order_key,
        hub_product_key,
        link_order_product_key
    FROM {{ ref('link_order_products') }}
),

-- The satellite table is constructed by joining the source data with the hub and link keys.
prepared AS (
    SELECT
        sd.*,
        lop.link_order_product_key,
        {{ dbt_utils.generate_surrogate_key(['sd.unit_price', 'sd.quantity', 'sd.discount']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_orders AS ho ON sd.order_id = ho.order_id
    INNER JOIN hub_products AS hp ON sd.product_id = hp.product_id
    INNER JOIN link_order_products AS lop
        ON
            ho.hub_order_key = lop.hub_order_key
            AND hp.hub_product_key = lop.hub_product_key
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['link_order_product_key', 'hashdiff']) }} AS sat_order_product_key,
    link_order_product_key,
    unit_price,
    quantity,
    discount,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
