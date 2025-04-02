{{ config(
    unique_key='sat_territory_key',
    merge_update_columns=['hashdiff', 'load_ts', 'territory_description', 'region_id', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_territories') }}
),
hub_keys AS (
    SELECT territory_id, hub_territory_key FROM {{ ref('hub_territories') }}
),
prepared AS (
    SELECT
        sd.*,
        hk.hub_territory_key,
        {{ dbt_utils.generate_surrogate_key(['sd.territory_description', 'sd.region_id']) }} AS hashdiff
    FROM source_data sd
    JOIN hub_keys hk ON sd.territory_id = hk.territory_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_territory_key', 'hashdiff']) }} AS sat_territory_key,
    hub_territory_key,
    territory_description,
    region_id,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp(6) with time zone) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}