-- This satellite table captures the attributes of regions in the Northwind database.
{{ config(
    unique_key='sat_region_key',
    merge_update_columns=['region_description', 'hashdiff', 'load_ts', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_region'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_region') }}
),

-- The hub table for regions is referenced to get the hub keys.
hub_keys AS (
    SELECT
        region_id,
        hub_region_key
    FROM {{ ref('hub_regions') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hk.hub_region_key,
        {{ dbt_utils.generate_surrogate_key(['sd.region_description']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.region_id = hk.region_id
)

-- Final selection of attributes for the satellite table.
SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_region_key', 'hashdiff']) }} AS sat_region_key,
    hub_region_key,
    region_description,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
