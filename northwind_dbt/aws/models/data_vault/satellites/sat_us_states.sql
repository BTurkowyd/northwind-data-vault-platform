-- This satellite table captures the attributes of US states in the Northwind database.
{{ config(
    unique_key='sat_state_key',
    merge_update_columns=['hashdiff', 'load_ts', 'state_name', 'state_abbr', 'state_region', 'record_source']
) }}

-- The satellite table is built from the staging model 'stg_us_states'.
WITH source_data AS (
    SELECT * FROM {{ ref('stg_us_states') }}
),

-- The hub table for US states is referenced to get the hub keys.
hub_keys AS (
    SELECT
        state_id,
        hub_state_key
    FROM {{ ref('hub_us_states') }}
),

-- The satellite table is constructed by joining the source data with the hub keys.
prepared AS (
    SELECT
        sd.*,
        hk.hub_state_key,
        {{ dbt_utils.generate_surrogate_key(['sd.state_name', 'sd.state_abbr', 'sd.state_region']) }} AS hashdiff
    FROM source_data AS sd
    INNER JOIN hub_keys AS hk ON sd.state_id = hk.state_id
)

-- Final selection of attributes for the satellite table.
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
