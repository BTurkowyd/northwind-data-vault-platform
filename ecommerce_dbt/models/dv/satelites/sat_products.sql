{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_product_key',
    merge_update_columns=['hashdiff', 'load_ts', 'name', 'category', 'price']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_products') }}
),
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
),
prepared AS (
    SELECT
        sd.*,
        hp.hub_product_key,
        {{ dbt_utils.generate_surrogate_key(['sd.name', 'sd.category', 'sd.price']) }} AS hashdiff
    FROM source_data sd
    JOIN hub_products hp ON sd.product_id = hp.product_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'hub_product_key',
        'hashdiff'
    ]) }} AS sat_product_key,

    hub_product_key,
    name,
    category,
    price,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts

FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}