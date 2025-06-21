-- This satellite table captures the attributes of territories in the Northwind database.
{{ config(
    unique_key='sat_territory_key',
    merge_update_columns=['hashdiff', 'load_ts', 'territory_description', 'region_id', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_territories'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_territories') }}
),

-- The hub table for territories is referenced to get the hub keys.
hub_keys AS (
    SELECT
        territory_id,
        hub_territory_key
    FROM {{ ref('hub_territories') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hk.hub_territory_key,
        {{ dbt_utils.generate_surrogate_key(['sd.territory_description', 'sd.region_id']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.territory_id = hk.territory_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_territory_key', 'hashdiff']) }} AS sat_territory_key,
    hub_territory_key,
    territory_description,
    region_id,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
