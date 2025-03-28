{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_key',
    merge_update_columns=['hashdiff', 'load_ts', 'total_amount', 'status']
) }}

-- The source_data CTE is a reference to the stg_orders model
WITH source_data AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
-- The hub_orders CTE is a reference to the hub_orders model
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
-- The prepared CTE joins the source_data and hub_orders CTEs
prepared AS (
    SELECT
        sd.*,
        ho.hub_order_key,
        {{ dbt_utils.generate_surrogate_key(['sd.total_amount', 'sd.status']) }} AS hashdiff
    FROM source_data sd
    -- The JOIN clause links the source_data and hub_orders CTEs on the order_id column
    JOIN hub_orders ho ON sd.order_id = ho.order_id
)

-- The final SELECT statement generates the surrogate key for the satellite table
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_order_key', 'hashdiff']) }} AS sat_order_key,
    hub_order_key,
    total_amount,
    status,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}