{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_product_key',
    merge_update_columns=['hashdiff', 'load_ts', 'name', 'category', 'price']
) }}

-- The source_data CTE is a reference to the stg_products model
WITH source_data AS (
    SELECT * FROM {{ ref('stg_products') }}
),
-- The hub_products CTE is a reference to the hub_products model
hub_products AS (
    SELECT product_id, hub_product_key FROM {{ ref('hub_products') }}
),
-- The prepared CTE joins the source_data and hub_products CTEs
prepared AS (
    SELECT
        sd.*,
        hp.hub_product_key,
        {{ dbt_utils.generate_surrogate_key(['sd.name', 'sd.category', 'sd.price']) }} AS hashdiff
    FROM source_data sd
    -- The JOIN clause links the source_data and hub_products CTEs on the product_id column
    JOIN hub_products hp ON sd.product_id = hp.product_id
)

-- The final SELECT statement generates the surrogate key for the satellite table
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_product_key', 'hashdiff']) }} AS sat_product_key,
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