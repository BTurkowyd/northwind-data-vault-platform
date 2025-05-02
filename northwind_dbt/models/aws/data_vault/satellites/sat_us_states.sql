{{ config(
    unique_key='sat_state_key',
    merge_update_columns=['hashdiff', 'load_ts', 'state_name', 'state_abbr', 'state_region', 'record_source']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('stg_us_states') }}
),

hub_keys AS (
    SELECT
        state_id,
        hub_state_key
    FROM {{ ref('hub_us_states') }}
),

prepared AS (
    SELECT
        sd.*,
        hk.hub_state_key,
        {{ dbt_utils.generate_surrogate_key(['sd.state_name', 'sd.state_abbr', 'sd.state_region']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.state_id = hk.state_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['hub_state_key', 'hashdiff']) }} AS sat_state_key,
    hub_state_key,
    state_name,
    state_abbr,
    state_region,
    hashdiff,
    CAST(CURRENT_TIMESTAMP AS timestamp (6)) AS load_ts,
    record_source
FROM prepared

{% if is_incremental() %}
    WHERE hashdiff NOT IN (SELECT hashdiff FROM {{ this }})
{% endif %}
