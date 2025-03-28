{{ config(
    materialized='incremental',
    table_type='iceberg',
    format='parquet',
    incremental_strategy='merge',
    unique_key='sat_customer_key',
    merge_update_columns=['hashdiff', 'load_ts', 'name', 'email']
) }}

-- The source_data CTE is a reference to the stg_customers model
WITH source_data AS (
    SELECT * FROM {{ ref('stg_customers') }}
),
-- The hub_keys CTE is a reference to the hub_customers model
hub_keys AS (
    SELECT customer_id, hub_customer_key FROM {{ ref('hub_customers') }}
),
-- The prepared CTE joins the source_data and hub_keys CTEs
prepared AS (
    SELECT
        sd.*,
        hk.hub_customer_key,
        {{ dbt_utils.generate_surrogate_key(['sd.name', 'sd.email']) }} AS hashdiff
    FROM source_data sd
    -- The JOIN clause links the source_data and hub_keys CTEs on the customer_id column
    JOIN hub_keys hk ON sd.customer_id = hk.customer_id
)
-- The final SELECT statement generates the surrogate key for the satellite table
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_customer_key', 'hashdiff']) }} AS sat_customer_key,
    hub_customer_key,
    name,
    email,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}