{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='link_order_product_key'
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_order_details') }}
),
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hp.hub_product_key']) }} AS link_order_product_key,
    ho.hub_order_key,
    hp.hub_product_key,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    sd.record_source
FROM source_data sd
JOIN hub_orders ho ON sd.order_id = ho.order_id
JOIN hub_products hp ON sd.product_id = hp.product_id

{% if is_incremental() %}
WHERE {{ dbt_utils.generate_surrogate_key(['ho.hub_order_key', 'hp.hub_product_key']) }}
  NOT IN (SELECT link_order_product_key FROM {{ this }})
{% endif %}