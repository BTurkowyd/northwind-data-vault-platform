-- This satellite table captures the attributes of customer types in the Northwind database.
{{ config(
    unique_key='sat_customer_type_key',
    merge_update_columns=['hashdiff', 'load_ts', 'customer_desc', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_customer_demographic'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_customer_demographic') }}
),

-- The hub table for customer types is referenced to get the hub keys.
hub_keys AS (
    SELECT
        customer_type_id,
        hub_customer_type_key
    FROM {{ ref('hub_customer_types') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        {{ dbt_utils.generate_surrogate_key(['sd.customer_desc']) }} AS hashdiff
    FROM source_data AS sd
)

-- Join the prepared data with the hub keys to get the final satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hk.hub_customer_type_key', 'p.hashdiff']) }} AS sat_customer_type_key,
    hk.hub_customer_type_key,
    p.customer_desc,
    p.hashdiff,
    p.record_source,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts
FROM prepared AS p
INNER JOIN hub_keys AS hk ON p.customer_type_id = hk.customer_type_id

{% if is_incremental() %}
    WHERE p.hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
