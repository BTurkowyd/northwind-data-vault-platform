{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_order_key',
    merge_update_columns=['hashdiff', 'load_ts', 'total_amount', 'status']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
hub_orders AS (
    SELECT order_id, hub_order_key FROM {{ ref('hub_orders') }}
),
prepared AS (
    SELECT
        sd.*,
        ho.hub_order_key,
        {{ dbt_utils.generate_surrogate_key(['sd.total_amount', 'sd.status']) }} AS hashdiff
    FROM source_data sd
    JOIN hub_orders ho ON sd.order_id = ho.order_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'hub_order_key',
        'hashdiff'
    ]) }} AS sat_order_key,

    hub_order_key,
    total_amount,
    status,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts

FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}