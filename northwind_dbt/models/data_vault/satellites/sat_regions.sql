{{ config(
    unique_key='sat_region_key',
    merge_update_columns=['region_description', 'hashdiff', 'load_ts', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_region') }}
),

hub_keys AS (
    SELECT
        region_id,
        hub_region_key
    FROM {{ ref('hub_regions') }}
),

prepared AS (
    SELECT
        sd.*,
        hk.hub_region_key,
        {{ dbt_utils.generate_surrogate_key(['sd.region_description']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.region_id = hk.region_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_region_key', 'hashdiff']) }} AS sat_region_key,
    hub_region_key,
    region_description,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
